// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class MonnifyService {
  // ─── CONFIG ───────────────────────────────────────────────────────────────
  // ⚠️ Move these to a backend/Edge Function before going to production.
  static const String _apiKey = 'MK_TEST_QLRRX9D9G2';
  static const String _secretKey = 'PMK3KYZFQV9CU1BAGB2TEYWZPMBRX05N';
  static const String _contractCode = '3826655799';

  // Switch to 'https://api.monnify.com' for production
  static const String _baseUrl = 'https://sandbox.monnify.com';

  // ─── TOKEN CACHE ──────────────────────────────────────────────────────────
  String? _cachedToken;
  DateTime? _tokenExpiry;

  final _supabase = Supabase.instance.client;

  // ─── AUTHENTICATE ─────────────────────────────────────────────────────────
  /// Returns a cached token if still valid, otherwise fetches a new one.
  /// Monnify tokens are valid for 1 hour; we refresh after 55 minutes.
  Future<String> authenticate() async {
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      print('Using cached Monnify token');
      return _cachedToken!;
    }

    print('Authenticating with Monnify...');

    final basicAuth =
        base64Encode(utf8.encode('$_apiKey:$_secretKey'));

    final res = await http.post(
      Uri.parse('$_baseUrl/api/v1/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $basicAuth',
      },
    );

    print('Auth status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception('Monnify auth failed: ${res.body}');
    }

    final data = json.decode(res.body);
    final token = data['responseBody']?['accessToken'] as String?;

    if (token == null) throw Exception('No access token returned from Monnify');

    _cachedToken = token;
    _tokenExpiry = DateTime.now().add(const Duration(minutes: 55));

    print('Monnify authenticated ✓');
    return token;
  }

  // ─── CREATE VIRTUAL ACCOUNT ───────────────────────────────────────────────
  /// Creates a Monnify reserved account for [userId] and saves it to Supabase.
  Future<void> createVirtualAccount(
      BuildContext context, String userId) async {
    void showMessage(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFF740690),
        ),
      );
    }

    try {
      print('Starting virtual account creation for user: $userId');

      // 1. Fetch user info from Supabase
      final userInfo = await _supabase
          .from('user_profile')
          .select('email, username, phone')
          .eq('user_id', userId)
          .maybeSingle();

      if (userInfo == null) throw Exception('User profile not found');

      final token = await authenticate();

      // 2. Create reserved account
      final payload = {
        'accountReference':
            'ACC_${userId.substring(0, 6)}_${DateTime.now().millisecondsSinceEpoch}',
        'accountName': userInfo['username'],
        'currencyCode': 'NGN',
        'contractCode': _contractCode,
        'customerEmail': userInfo['email'],
        'customerName': userInfo['username'],
        'getAllAvailableBanks': false,
        'preferredBanks': ['035'], // Wema Bank
        // 'bvn': userInfo['bvn'], // ← uncomment when you collect real BVN
      };

      final createRes = await http.post(
        Uri.parse('$_baseUrl/api/v2/bank-transfer/reserved-accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print('Create account status: ${createRes.statusCode}');
      print('Create body: ${createRes.body}');

      final createData = json.decode(createRes.body);

      if (createData['requestSuccessful'] != true) {
        throw Exception(
            'Account creation failed: ${createData['responseMessage']}');
      }

      final responseBody = createData['responseBody'];
      final accounts = responseBody['accounts'] as List?;

      if (accounts == null || accounts.isEmpty) {
        throw Exception('No account data returned from Monnify');
      }

      final accountNumber = accounts.first['accountNumber'] as String;
      final accountRef = responseBody['accountReference'] as String;
      const bankName = 'Wema Bank';

      // 3. Fetch initial balance
      final balance = await getVirtualAccountBalance(accountRef);

      // 4. Persist to Supabase
      await _saveMonnifyAccountToSupabase(
        userId: userId,
        accountNumber: accountNumber,
        accountRef: accountRef,
        bankName: bankName,
        balance: balance,
      );

      showMessage('Virtual account created successfully!');
    } catch (e) {
      print('Error creating virtual account: $e');
      showMessage('Failed to create virtual account. Please try again.');
      rethrow;
    }
  }

  // ─── GET BALANCE ──────────────────────────────────────────────────────────
  /// Returns the current balance for the given reserved account reference.
  Future<double> getVirtualAccountBalance(String accountRef) async {
    final token = await authenticate();

    print('Fetching balance for: $accountRef');

    final res = await http.get(
      Uri.parse(
          '$_baseUrl/api/v2/bank-transfer/reserved-accounts/$accountRef'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Balance status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch balance: ${res.body}');
    }

    final data = json.decode(res.body);
    final balance = data['responseBody']?['totalAmount'] ?? 0.0;

    return (balance as num).toDouble();
  }

  // ─── FETCH TRANSACTIONS ───────────────────────────────────────────────────
  /// Returns paginated transactions for a specific reserved account.
  Future<List<dynamic>> fetchTransactions(
    String accountRef, {
    int page = 0,
    int size = 20,
  }) async {
    final token = await authenticate();

    final uri = Uri.parse(
      '$_baseUrl/api/v1/bank-transfer/reserved-accounts/transactions'
      '?accountReference=$accountRef&page=$page&size=$size',
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Transactions status: ${res.statusCode}');

    if (res.statusCode != 200) {
      print('Failed to fetch transactions: ${res.body}');
      return [];
    }

    final data = json.decode(res.body);
    return data['responseBody']?['content'] ?? [];
  }

  // ─── VERIFY TRANSACTION ───────────────────────────────────────────────────
  /// Verifies a transaction by its reference. Always verify server-side
  /// before granting value to the user.
  Future<Map<String, dynamic>> verifyTransaction(
      String transactionRef) async {
    final token = await authenticate();
    final encodedRef = Uri.encodeComponent(transactionRef);

    final res = await http.get(
      Uri.parse('$_baseUrl/api/v2/transactions/$encodedRef'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Transaction verification failed: ${res.body}');
    }

    final data = json.decode(res.body);
    return data['responseBody'] as Map<String, dynamic>;

    // Check: responseBody['paymentStatus'] == 'PAID'
  }

  // ─── SAVE TO SUPABASE (PRIVATE) ───────────────────────────────────────────
  Future<void> _saveMonnifyAccountToSupabase({
    required String userId,
    required String accountNumber,
    required String accountRef,
    required String bankName,
    required double balance,
  }) async {
    print('Saving account to Supabase...');

    await _supabase.from('user_profile').update({
      'account_number': accountNumber,
      'account_ref': accountRef,
      'bank_name': bankName,
      'balance': balance,
    }).eq('user_id', userId);

    print('Supabase update complete ✓');
  }
}
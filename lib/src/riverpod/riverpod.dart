import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pacervtu/src/model/bankdatamodel.dart';
import 'package:pacervtu/src/model/recenttransactionmodel.dart';
import 'package:pacervtu/src/services/monnify_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class UserProfileNotifier extends StateNotifier<UserModel?> {
  UserProfileNotifier() : super(null);

  void setUser(UserModel user) => state = user;

  void clearUser() => state = null;
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserModel?>((ref) {
  return UserProfileNotifier();
});

final userProfileStreamProvider = StreamProvider.autoDispose<UserModel>((ref) {
  final supabase = Supabase.instance.client;
  final currentUser = ref.watch(userProfileProvider);

  if (currentUser == null || currentUser.userId.isEmpty) {
    return const Stream<UserModel>.empty();
  }

  final userId = currentUser.userId;

  final stream = supabase
      .from('user_profile')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((event) {
    if (event.isNotEmpty) {
      return UserModel.fromMap(event.first);
    } else {
      return UserModel(
        userId: '',
        username: 'New user',
        email: 'Unavailable',
        phone: 'N/A',
        bankname: 'N/A',
        accountnumber: 'N/A',
        accountRef: 'N/A', balance: 0.0,
      );
    }
  });

  return stream;
});


// User Balance display Stream Riverpod

final userBalanceStreamProvider = StreamProvider.autoDispose<double>((ref) {
  final supabase = Supabase.instance.client;

  final user = supabase.auth.currentUser;
  if (user == null) {
    return const Stream.empty();
  }

  return supabase
      .from('user_profile')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', user.id)
      .map((rows) {
        if (rows.isEmpty) return 0.0;

        final row = rows.first;
        final bal = row['balance'];

        return (bal == null) ? 0.0 : (bal as num).toDouble();
      });
});

final fetchBalanceOnLoginProvider = Provider.autoDispose((ref) {
  final supabase = Supabase.instance.client;
  final currentUser = supabase.auth.currentUser;

  if (currentUser == null) return;

  final userProfile = ref.watch(userProfileProvider);
  if (userProfile == null || userProfile.accountRef.isEmpty) return;

  Future.microtask(() async {
    try {
      final monnify = MonnifyService();

      final balance =
          await monnify.getVirtualAccountBalance(userProfile.accountRef);

      await supabase
          .from("user_profile")
          .update({"balance": balance})
          .eq("user_id", currentUser.id);

      print("Balance synced: ₦$balance");
    } catch (e) {
      print("Balance sync error: $e");
    }
  });
});


// Recent Transactions Stream and riverpod

final recentTransactionsProvider =
    StreamProvider.autoDispose<List<UserServiceModel>>((ref) {
  final supabase = Supabase.instance.client;

  final user = supabase.auth.currentUser;
  if (user == null) return const Stream.empty();

  final stream = supabase
      .from('user_services')
      .stream(primaryKey: ['id'])
      .eq('user_id', user.id)
      .order('created_at', ascending: false)
      .map((rows) => rows.map((e) => UserServiceModel.fromJson(e)).toList());

  return stream;
});




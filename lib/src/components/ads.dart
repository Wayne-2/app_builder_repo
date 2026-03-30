// import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RandomImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const RandomImageCarousel({super.key, required this.imageUrls});

  @override
  State<RandomImageCarousel> createState() => _RandomImageCarouselState();
}

class _RandomImageCarouselState extends State<RandomImageCarousel> {
  late List<String> shuffledImages;

  @override
  void initState() {
    super.initState();

    shuffledImages = List.from(widget.imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: CarouselSlider(
          options: CarouselOptions(
            height: 100,
            autoPlay: true,
            viewportFraction: 1.0, 
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            enableInfiniteScroll: true,
          ),
          items: shuffledImages.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100,
                placeholder: (context, _) => Container(
                  color: Colors.grey.shade200,
                  width: double.infinity,
                  height: 100,
                ),
                errorWidget: (context, _, _) => Center(child: const Text('unable to load to ads')),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


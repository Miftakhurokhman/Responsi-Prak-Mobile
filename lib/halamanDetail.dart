import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'modelDetailMeal.dart';

class HalamanDetail extends StatefulWidget {
  final String id;
  const HalamanDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<HalamanDetail> createState() => _HalamanDetailState();
}

class _HalamanDetailState extends State<HalamanDetail> {
  late Future<List<DetailMeal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = fetchMeals();
  }
  Future<List<DetailMeal>> fetchMeals() async {
    final response = await http.get(Uri.parse("https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.id}"));
    if (response.statusCode == 200) {
      List<DetailMeal> meals = (json.decode(response.body)['meals'] as List)
          .map((data) => DetailMeal.fromJson(data))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to load meals');
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Detail"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
          child: FutureBuilder<List<DetailMeal>>(
            future: _meals,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No meals found.'),
                );
              } else {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.075),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Container(
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data![0].strMealThumb)
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text(
                            "${snapshot.data![0].strMeal}",
                          style: TextStyle(
                            fontSize: 25
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

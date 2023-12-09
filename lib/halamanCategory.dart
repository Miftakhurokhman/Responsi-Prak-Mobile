import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsi/halamanDetail.dart';
import 'modelJenisCategory.dart';

class HalamanCategory extends StatefulWidget {
  final String category;

  const HalamanCategory({Key? key, required this.category}) : super(key: key);

  @override
  State<HalamanCategory> createState() => _HalamanCategoryState();
}

class _HalamanCategoryState extends State<HalamanCategory> {
  late Future<List<Meal>> _meals;

  @override
  void initState() {
    super.initState();
    _meals = fetchMeals();
  }

  Future<List<Meal>> fetchMeals() async {
    final response = await http.get(Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}"));
    if (response.statusCode == 200) {
      List<Meal> meals = (json.decode(response.body)['meals'] as List)
          .map((data) => Meal.fromJson(data))
          .toList();
      return meals;
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Meals"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.075),
        child: FutureBuilder<List<Meal>>(
          future: _meals,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
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
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Meal meal = snapshot.data![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => HalamanDetail(id: meal.idMeal)));
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(meal.strMealThumb),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  meal.strMeal,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

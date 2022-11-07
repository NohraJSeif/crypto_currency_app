import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/coin_details.dart';

class CoinGraphScreen extends StatefulWidget {
  final CoinDetailsModel coinDetailsModel;
  const CoinGraphScreen({
    super.key,
    required this.coinDetailsModel,
  });

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  bool isLoading = true, isFirstTime = true;
  List<FlSpot> flSpotList = [];
  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;

  @override
  void initState() {
    super.initState();
    getChartData("1");
  }

  void getChartData(String days) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }
    String apiUrl =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetailsModel.id}/market_chart?vs_currency=cad&days=$days";

    Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> result = json.decode(response.body);

      List rawList = result['prices'];
      List<List> chartData = rawList.map((e) => e as List).toList();

      List<PriceAndTime> priceAndTimeList = chartData
          .map((e) => PriceAndTime(
                time: e[0] as int,
                price: e[1] as double,
              ))
          .toList();

      flSpotList = [];

      for (var element in priceAndTimeList) {
        flSpotList.add(FlSpot(
          element.time.toDouble(),
          element.price,
        ));
      }

      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      var highest = priceAndTimeList.first.price;
      var lowest = priceAndTimeList.first.price;

      for (var i = 0; i < priceAndTimeList.length; i++) {
        if (priceAndTimeList[i].price < lowest) {
          lowest = priceAndTimeList[i].price;
        }
        if (priceAndTimeList[i].price > highest) {
          highest = priceAndTimeList[i].price;
        }
      }

      minY = lowest;
      maxY = highest;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: Text(
            widget.coinDetailsModel.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: "${widget.coinDetailsModel.name} Price\n",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(
                          text: "CAD ${widget.coinDetailsModel.currentPrice}\n",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${widget.coinDetailsModel.priceChangePercentage24h}%",
                          style: TextStyle(
                            color: widget.coinDetailsModel
                                        .priceChangePercentage24h >
                                    0
                                ? Colors.green
                                : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              isLoading == false
                  ? Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: LineChart(
                                LineChartData(
                                  minX: minX,
                                  minY: minY,
                                  maxX: maxX,
                                  maxY: maxY,
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: false,
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: (SideTitles(
                                        showTitles: false,
                                      )),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(
                                              "${meta.formattedValue}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    show: true,
                                  ),
                                  gridData: FlGridData(
                                      getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      strokeWidth: 0,
                                    );
                                  }, getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      strokeWidth: 0,
                                    );
                                  }),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: flSpotList,
                                      dotData: FlDotData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // todo change color of clicked button
                                      getChartData("1");
                                    },
                                    child: const Text("1d"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      getChartData("15");
                                    },
                                    child: const Text("15d"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      getChartData("30");
                                    },
                                    child: const Text("30d"),
                                  ),
                                ]),
                          )
                        ],
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ],
          ),
        ));
  }
}

class PriceAndTime {
  late int time;
  late double price;

  PriceAndTime({
    required this.time,
    required this.price,
  });
}

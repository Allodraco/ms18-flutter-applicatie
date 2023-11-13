import 'package:flutter/material.dart';
import 'package:ms18_applicatie/Models/stock.dart';
import 'package:ms18_applicatie/Stock/widgets.dart';
import 'package:ms18_applicatie/Widgets/pageHeader.dart';
import 'package:ms18_applicatie/config.dart';
import 'package:ms18_applicatie/menu.dart';
class ApiService {
  Future<List<StockProduct>> getStockProducts() async {
    // Simulate an API request delay
    await Future.delayed(Duration(seconds: 1));

    // Return test list of stock products
    return [
      StockProduct(
        product: Product(
        priceQuantity: 1,
        color: Colors.redAccent,
        name: 'Bier',
        price: 2.43,
      ),
      quantity: 40,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.blueAccent,
          name: 'Cola',
          price: 3.13,
        ),
        quantity: 21,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.redAccent,
          name: 'Bier',
          price: 2.43,
        ),
        quantity: 40,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.yellowAccent,
          name: 'Fanta',
          price: 6.81,
        ),
        quantity: 12,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.redAccent,
          name: 'Bier',
          price: 2.43,
        ),
        quantity: 40,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.greenAccent,
          name: 'Wiskey',
          price: 0.43,
        ),
        quantity: 8,
      ),
      StockProduct(
        product: Product(
          priceQuantity: 1,
          color: Colors.redAccent,
          name: 'Bier',
          price: 2.43,
        ),
        quantity: 40,
      ),
    ];
  }
}
class StockReport extends StatefulWidget {
  const StockReport({Key? key}) : super(key: key);

  @override
  State<StockReport> createState() => StockReportState();
}
class StockReportState extends State<StockReport> {
  final ApiService apiService = ApiService();
  List<StockProduct> stockProducts = [];

  @override
  void initState() {
    super.initState();
    _loadStockProducts();
  }

  Future<void> _loadStockProducts() async {
    final List<StockProduct> products = await apiService.getStockProducts();
    setState(() {
      stockProducts = products;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Menu(
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PageHeader(
              title: "Voorraad beheer",
              onAdd: () {
                addItemsDialog(context, (stockProduct) {});
              },
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(mobilePadding),
                shrinkWrap: true,
                itemCount: stockProducts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return StockElement(
                    stockProduct: stockProducts[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  runApp(const MyApp());
}

InAppPurchase _inAppPurchase = InAppPurchase.instance;
late StreamSubscription<dynamic> _streamSubscription;

List<ProductDetails> _products = [];

const _variant = {"amplifyabhi", "amplifyabhi pro"};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Stream purchaseUpdate = InAppPurchase.instance.purchaseStream;

    _streamSubscription = purchaseUpdate.listen((purchaseList) {
      _listenToPurchase(purchaseList, context);
    }, onDone: () {
      _streamSubscription.cancel();
    }, onError: (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    });

    initStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchase in Flutter"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            buy();
          },
          child: Text("Buy"),
        ),
      ),
    );
  }

  initStore() async {
    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(_variant);
    if (productDetailsResponse.error != null) {
      print("Error loading products: ${productDetailsResponse.error}");
    } else {
      setState(() {
        _products = productDetailsResponse.productDetails;
      });
    }
  }
}

_listenToPurchase(
    List<PurchaseDetails> purchaseDetailsList, BuildContext context) {
  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pending")));
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    } else if (purchaseDetails.status == PurchaseStatus.purchased) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Purchased")));
    }
  });
}

buy() {
  if (_products.isNotEmpty) {
    final PurchaseParam param = PurchaseParam(productDetails: _products[0]);
    _inAppPurchase.buyConsumable(purchaseParam: param);
  } else {
    print("No products");
  }
}

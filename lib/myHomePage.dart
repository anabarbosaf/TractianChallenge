import 'package:flutter/material.dart';
import 'package:flutter_challenge/company.dart';
import 'package:flutter_challenge/companyAssetPage.dart';
import 'package:flutter_challenge/companyService.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Company>> _companies;

  @override
  void initState() {
    super.initState();
    _companies = CompanyService.fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/header.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: const Text(''),
          backgroundColor: Colors.transparent, 
          elevation: 0, 
        ),
      ),
      body: FutureBuilder<List<Company>>(
        future: _companies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<Company> companies = snapshot.data!;
            return ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  padding: const EdgeInsets.all(12.0),
                  
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(198, 18, 148, 254),
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(companies[index].name),
                    textColor: Colors.white,
                    onTap: () {
                      _navigateToCompanyAssetsPage(companies[index].id);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToCompanyAssetsPage(String companyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyAssetsPage(companyId: companyId),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/adminpetprofile.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:geopawsfinal/formpet.dart';
import 'package:geopawsfinal/petprofile.dart';

void main() {
  runApp(const PetPage());
}

// ignore: camel_case_types
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PetPage createState() => _PetPage();
}

// ignore: camel_case_types
class _PetPage extends State<PetPage> {
  final searchController = TextEditingController();
  String searchText = "";
  String selectedFilter = "Type"; // Default filter
  String selectedOption = "All"; // Default option for the secondary dropdown
  List<String> filterOptions = [
    "All"
  ]; // List of options for the selected filter

  String appliedFilter = "Type"; // Applied filter
  String appliedOption = "All"; // Applied option

  @override
  void initState() {
    super.initState();
    fetchFilterOptions(); // Fetch options for the default filter initially
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
  }

  Future<void> fetchFilterOptions() async {
    final filterField = selectedFilter.toLowerCase();
    final snapshot = await FirebaseFirestore.instance.collection('pet').get();
    final options = snapshot.docs
        .map((doc) => doc.data()[filterField].toString())
        .toSet() // Convert to set to remove duplicates
        .toList();
    setState(() {
      filterOptions = ["All", ...options];
      selectedOption =
          filterOptions.contains(selectedOption) ? selectedOption : "All";
    });
  }

  void clearFilters() {
    setState(() {
      selectedFilter = "Type";
      selectedOption = "All";
      filterOptions = ["All"];
      searchController.clear();
      searchText = "";
      appliedFilter = "Type";
      appliedOption = "All";
      fetchFilterOptions();
    });
  }

  void applyFilters() {
    setState(() {
      appliedFilter = selectedFilter;
      appliedOption = selectedOption;
    });
    Navigator.pop(context);
  }

  void showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This makes the modal cover the full screen height
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                height: MediaQuery.of(context).size.height *
                    0.5, // Set height to half of the screen
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Ensure it takes the full width
                  children: [
                    DropdownButton<String>(
                      value: selectedFilter,
                      items: <String>['Type', 'pet_name', 'Age', 'Color', 'Sex']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedFilter = newValue!;
                          fetchFilterOptions(); // Fetch new options when filter changes
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    if (filterOptions.isNotEmpty)
                      DropdownButton<String>(
                        value: filterOptions.contains(selectedOption)
                            ? selectedOption
                            : filterOptions[0],
                        items: filterOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedOption = newValue!;
                          });
                        },
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: applyFilters,
                      child: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    TextButton(
                      onPressed: () {
                        clearFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 63, 157),
          title: Row(
            children: [
              GestureDetector(
                child: const Icon(
                  Icons.arrow_left,
                  size: 40,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomPage(),
                      ));
                },
              ),
              const Text(
                'Pet',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Text(
                  'Pet for Adoption',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => showFilterModal(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pet')
                      .where('status', isEqualTo: 'Available')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: Text('No data available'),
                      );
                    }
                    final alldata = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final matchesFilter = appliedOption == "All" ||
                          (data[appliedFilter.toLowerCase()] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(appliedOption.toLowerCase());
                      final matchesSearch = searchText.isEmpty ||
                          (data['type'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(searchText) ||
                          (data['pet_name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(searchText);
                      return matchesFilter && matchesSearch;
                    }).toList();

                    if (alldata.isEmpty) {
                      return const Center(
                        child: Text('No pets available for adoption'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap:
                          true, // Important to use shrinkWrap inside a ListView
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling to avoid conflicts
                      itemCount: alldata.length,
                      itemBuilder: (context, index) {
                        final data = alldata[index];
                        // Access your fields from Firestore document
                        final type = data['type'] ?? 'Unnamed';
                        final pet_name = data['pet_name'] ?? 'Unnamed';

                        final docId = data.id; // Access the document ID here
                        // Assuming you have an image field in Firestore

                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 239, 239, 239),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue,
                                        borderRadius: BorderRadius.circular(55),
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          data['images'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit
                                              .cover, // This ensures the image covers the circular area
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset('assets/p1.png',
                                                width: 60, height: 60);
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              pet_name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      child: const FaIcon(
                                        FontAwesomeIcons.chevronCircleRight,
                                        color: Color.fromARGB(255, 0, 63, 157),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            PetProfilePage(docId: docId))));
                              }),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

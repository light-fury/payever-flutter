import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import 'new_product.dart';

class ProductCategoryRow extends StatefulWidget {
  final NewProductScreenParts parts;

  ProductCategoryRow({@required this.parts});

  @override
  createState() => _ProductCategoryRowState();
}

class _ProductCategoryRowState extends State<ProductCategoryRow> {
  String getCat;

  List<String> suggestions = List();
  String doc = "";
  String currentCat = "";

  @override
  void initState() {
    super.initState();
    if (widget.parts.editMode) {
      widget.parts.product.categories.forEach((f) {
        widget.parts.categoryList.add(f.title);
      });
    }
    getCat = '''
    query getCategory{getCategories(businessUuid: "${widget.parts.business}", title: "", pageNumber: 1, paginationLimit: 1000) {
           _id    
           slug    
           title    
           businessUuid
          }
          }
    ''';

    doc = getCat;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              //width: Measurements.width * 0.9,
              height: widget.parts.categoryList.isEmpty
                  ? 0
                  : Measurements.height * (widget.parts.isTablet ? 0.05 : 0.07),
              child: Container(
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.parts.categoryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding:
                          EdgeInsets.only(right: Measurements.width * 0.015),
                      child: Chip(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        label: Text(
                          widget.parts.categoryList[index],
                          style: TextStyle(
                              fontSize: AppStyle.fontSizeTabContent()),
                        ),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            widget.parts.categoryList.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              )),
          GraphQLProvider(
            client: widget.parts.client,
            child: Query(
              key: widget.parts.qKey,
              options:
                  QueryOptions(variables: <String, dynamic>{}, document: doc),
              builder: (QueryResult result, {VoidCallback refetch}) {
                if (result.errors != null) {
                  print(result.errors);
                  return Center(
                    child: Text("Error loading"),
                  );
                }
                if (result.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                suggestions = List();
                if (result.data["createCategory"] != null) {
                  widget.parts.categories
                      .add(Categories.toMap(result.data["createCategory"]));
                  doc = getCat;
                }
                if (result.data["getCategories"] != null) {
                  result.data["getCategories"].forEach((a) {
                    widget.parts.categories.add(Categories.toMap(a));
                    suggestions.add(a["title"]);
                  });
                }
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: Measurements.width * 0.025),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16)),
                  //width: Measurements.width * 0.9,
                  height: Measurements.height *
                      (widget.parts.isTablet ? 0.05 : 0.07),
                  child: SimpleAutoCompleteTextField(
                    style: TextStyle(fontSize: AppStyle.fontSizeTabContent()),
                    textSubmitted: (text) {
                      setState(() {
                        bool contained = true;
                        widget.parts.categories.forEach((s) {
                          if (s.title
                                  .toLowerCase()
                                  .compareTo(text.toLowerCase()) ==
                              0) contained = false;
                        });
                        if (contained) {
                          print("NEW Category");
                          doc = '''mutation createCategory {
                            createCategory(category: {businessUuid: "${widget.parts.business}", title: "$text"}) {
                                _id
                                businessUuid
                                title
                                slug
                              }
                            }''';
                        } else {
                          print("OLD");
                        }
                        widget.parts.categoryList.add(text);
                      });
                    },
                    suggestionsAmount: 5,
                    decoration: InputDecoration(
                      hintText:
                          Language.getProductStrings("category.add_category"),
                      border: InputBorder.none,
                    ),
                    key: widget.parts.atfKey,
                    suggestions: suggestions,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

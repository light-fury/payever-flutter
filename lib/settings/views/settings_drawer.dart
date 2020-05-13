import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'employees/employees_screen.dart';

class SettingsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black.withOpacity(0.1),
        child: ListView(
          children: <Widget>[
            ListTile(
                leading: Icon(
                  Icons.perm_identity,
                  color: Colors.white,
                ),
                title: Text("Employees",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      PageTransition(
                        child: EmployeesScreen(),
                        type: PageTransitionType.fade,
                      ));
                }),
          ],
        ),
      ),
    );
  }
}

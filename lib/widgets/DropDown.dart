import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SiteDropdown extends StatefulWidget {
  final String hint;
  final Color colour;
  final IconData icon;
  final Color hintColor;
  final Color borderColor;
  final List<Site> list;
  final Function onChange;
  String selectedvalue;
  final Color textColor;
  final bool edit;

  SiteDropdown(
      {this.hint,
      this.colour,
      this.icon,
      this.hintColor,
      this.borderColor,
      this.list,
      this.selectedvalue,
      this.onChange,
      this.textColor,
      this.edit});

  @override
  _SiteDropdownState createState() => _SiteDropdownState();
}

class _SiteDropdownState extends State<SiteDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      height: 48.h,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down),
            Expanded(
              child: DropdownButton(
                icon: Icon(
                  widget.icon,
                  color: Colors.orange,
                ),
                elevation: 2,
                isExpanded: true,
                items: widget.list.map((Site x) {
                  return DropdownMenuItem<String>(
                      value: x.name,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                height: 20.h,
                                child: AutoSizeText(
                                  x.name,
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ));
                }).toList(),
                onChanged: (value) {
                  widget.onChange(value);
                  setState(() {
                    widget.selectedvalue = value;
                  });
                },
                value: widget.selectedvalue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundedBorderDropdown extends StatefulWidget {
  final String hint;
  final Color colour;
  final IconData icon;
  final Color hintColor;
  final Color borderColor;
  final List<String> list;
  final Function onChange;
  String selectedvalue;
  final Color textColor;
  final edit;

  RoundedBorderDropdown(
      {this.hint,
      this.edit,
      this.colour,
      this.icon,
      this.hintColor,
      this.borderColor,
      this.list,
      this.selectedvalue,
      this.onChange,
      this.textColor});

  @override
  _RoundedBorderDropdownState createState() => _RoundedBorderDropdownState();
}

class _RoundedBorderDropdownState extends State<RoundedBorderDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(15),
      //     border: Border.all(
      //         color: widget.edit ? Colors.black : Colors.black12, width: 1)),
      height: 48.h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down),
            Expanded(
              child: DropdownButton(
                icon: Icon(
                  widget.icon,
                  color: Colors.orange,
                ),
                elevation: 2,
                isExpanded: true,
                items: widget.list.map((String x) {
                  return DropdownMenuItem<String>(
                      value: x,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                height: 20,
                                child: AutoSizeText(
                                  x,
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ));
                }).toList(),
                onChanged: (value) {
                  widget.onChange(value);
                  setState(() {
                    widget.selectedvalue = value;
                  });
                },
                value: widget.selectedvalue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShiftsDropDown extends StatefulWidget {
  final String hint;
  final Color colour;
  final IconData icon;
  final Color hintColor;
  final Color borderColor;
  final List<Shift> list;
  final Function onChange;
  String selectedvalue;
  final Color textColor;
  final bool edit;

  ShiftsDropDown(
      {this.hint,
      this.colour,
      this.icon,
      this.hintColor,
      this.borderColor,
      this.list,
      this.selectedvalue,
      this.onChange,
      this.textColor,
      this.edit});

  @override
  _ShiftsDropDownState createState() => _ShiftsDropDownState();
}

class _ShiftsDropDownState extends State<ShiftsDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(Icons.arrow_drop_down),
            Expanded(
              child: DropdownButton(
                icon: Icon(
                  widget.icon,
                  color: Colors.orange,
                ),
                elevation: 2,
                isExpanded: true,
                items: widget.list.map((Shift x) {
                  return DropdownMenuItem<String>(
                      value: x.shiftName,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                height: 20,
                                child: AutoSizeText(
                                  x.shiftName,
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ));
                }).toList(),
                onChanged: (value) {
                  widget.onChange(value);
                  setState(() {
                    widget.selectedvalue = value;
                  });
                },
                value: widget.selectedvalue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

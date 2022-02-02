import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/site_shifts_all.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SiteDropdown extends StatefulWidget {
  final String hint;
  final Color colour;
  final IconData icon;
  final Color hintColor;
  final Color borderColor;
  final List<SiteShiftsModel> list;
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(),
        height: 50.h,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, right: 10, left: 5),
          child: Row(
            children: [
              const Icon(Icons.arrow_drop_down),
              Expanded(
                child: DropdownButton(
                  underline: const Divider(
                    thickness: 1,
                    color: Colors.grey,
                    height: 3,
                  ),
                  isDense: true,
                  icon: Icon(
                    widget.icon,
                    color: Colors.orange,
                  ),
                  elevation: 2,
                  isExpanded: true,
                  items: widget.list.map((SiteShiftsModel x) {
                    return DropdownMenuItem<String>(
                        value: x.siteName,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                  height: 25.h,
                                  child: AutoSizeText(
                                    x.siteName,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: setResponsiveFontSize(14),
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.right,
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
  final List<Shifts> list;
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
                hint: Align(
                  alignment: Alignment.centerRight,
                  child: AutoSizeText(
                    "لا يوجد مناوبات",
                    textAlign: TextAlign.right,
                  ),
                ),
                icon: Icon(
                  widget.icon,
                  color: Colors.orange,
                ),
                elevation: 2,
                isExpanded: true,
                items: widget.list.map((Shifts x) {
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

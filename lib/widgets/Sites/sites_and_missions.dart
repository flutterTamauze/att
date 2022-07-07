import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';

import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SitesAndMissionsWidg extends StatefulWidget {
  final Function onchannge;
  const SitesAndMissionsWidg({
    this.onchannge,
    Key key,
    @required this.prov,
    @required this.selectedVal,
    @required this.list,
  }) : super(key: key);

  final SiteData prov;
  final String selectedVal;
  final List<Site> list;

  @override
  _SitesAndMissionsWidgState createState() => _SitesAndMissionsWidgState();
}

class _SitesAndMissionsWidgState extends State<SitesAndMissionsWidg> {
  @override
  Widget build(BuildContext context) {
    int holder;
    return Column(
      children: [
        VacationCardHeader(
            header: getTranslated(
          context,
          "الموقع و المناوبة للمأمورية",
        )),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 60.h,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Consumer<SiteShiftsData>(
                            builder: (context, value, child) {
                              return IgnorePointer(
                                ignoring: widget.prov.siteValue == "كل المواقع"
                                    ? true
                                    : false,
                                child: DropdownButton(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    elevation: 5,
                                    items: value.shifts
                                        .map(
                                          (value) => DropdownMenuItem(
                                              child: Container(
                                                  height: 20.h,
                                                  child: AutoSizeText(
                                                    value.shiftName,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: ScreenUtil()
                                                            .setSp(12,
                                                                allowFontScalingSelf:
                                                                    true),
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )),
                                              value: value.shiftName),
                                        )
                                        .toList(),
                                    onChanged: (v) async {
                                      if (widget.selectedVal != "كل المواقع") {
                                        final List<String> x = [];

                                        value.shifts.forEach((element) {
                                          x.add(element.shiftName);
                                        });
                                        setState(() {
                                          debugPrint("on changed $v");
                                          holder = x.indexOf(v);

                                          Provider.of<SiteData>(context,
                                                  listen: false)
                                              .setDropDownShift(holder);
                                        });
                                      }
                                    },
                                    hint: AutoSizeText(
                                        getTranslated(context, "كل المناوبات")),
                                    value: widget.prov.siteValue == "كل المواقع"
                                        ? null
                                        : value
                                            .shifts[Provider.of<SiteData>(
                                                    context,
                                                    listen: true)
                                                .dropDownShiftIndex]
                                            .shiftName

                                    // value
                                    ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.alarm,
                  color: Colors.orange[600],
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          Consumer<ShiftsData>(
                            builder: (context, value, child) {
                              return DropdownButton(
                                isExpanded: true,
                                underline: const SizedBox(),
                                elevation: 5,
                                items: widget.list
                                    .map((value) => DropdownMenuItem(
                                          child: Container(
                                            height: 20,
                                            child: AutoSizeText(
                                              value.name,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: ScreenUtil().setSp(
                                                      12,
                                                      allowFontScalingSelf:
                                                          true),
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          value: value.name,
                                        ))
                                    .toList(),
                                onChanged: (v) async {
                                  widget.prov.setDropDownShift(0);
                                  Provider.of<SiteShiftsData>(context,
                                          listen: false)
                                      .getShiftsList(v, false);
                                  if (v != "كل المواقع") {
                                    widget.prov.setDropDownIndex(widget
                                            .prov.dropDownSitesStrings
                                            .indexOf(v) -
                                        1);
                                  } else {
                                    widget.prov.setDropDownIndex(0);
                                  }

                                  widget.prov.fillCurrentShiftID(widget
                                      .list[widget.prov.dropDownSitesIndex + 1]
                                      .id);

                                  widget.prov.setSiteValue(v);
                                  widget.onchannge(v);
                                },
                                value: widget.selectedVal,
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.location_on,
                  color: ColorManager.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

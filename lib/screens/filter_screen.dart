import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/provider/filter_provider.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

import '../model/city_model.dart';
import '../provider/user_provider.dart';
import '../utils/constants.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  var _departureController=TextEditingController();
  var _arrivalController=TextEditingController();
  var _dateController=TextEditingController();
  var _timeStartController=TextEditingController();
  var _timeEndController=TextEditingController();
  var _priceEndController=TextEditingController();
  var _priceStartController=TextEditingController();

  String selectedGender='Male'.tr();
  String gender='Male';
  List<String> genders = <String>['Male'.tr(), 'Female'.tr(), 'Both'.tr()];





  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<FilterProvider>(context, listen: false);



      _departureController.text=provider.departure.tr();
      _arrivalController.text=provider.arrival.tr();
      _priceStartController.text=provider.priceStart.toString();
      _priceEndController.text=provider.priceEnd.toString();
      _arrivalController.text=provider.arrival.tr();
      _dateController.text='${df.format(provider.startDate)} - ${df.format(provider.endDate)}';
      _timeStartController.text='${tf.format(provider.startDate)}';
      _timeEndController.text='${tf.format(provider.endDate)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Drawer(
      child: SafeArea(
        child: Consumer<FilterProvider>(
          builder: (context, provider, child) {

            return Container(
              height: MediaQuery.of(context).size.height,
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 15,),
                  if(!provider.allRides)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price'.tr(),style: TextStyle(fontSize:18),),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text'.tr();
                                }
                                return null;
                              },
                              onChanged: (value){
                                if(value.isNotEmpty){
                                  if(double.parse(value)<0){
                                    _priceStartController.text=0.toString();
                                  }
                                  provider.setPriceStart(double.parse(_priceStartController.text.trim()));
                                }
                              },
                              controller: _priceStartController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.5
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: '0 ${'JOD'.tr()}',
                                // If  you are using latest version of flutter then lable text and hint text shown like this
                                // if you r using flutter less then 1.20.* then maybe this is not working properly
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('to'.tr()),
                          ),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text'.tr();
                                }
                                return null;
                              },
                              onChanged: (value){
                                if(value.isNotEmpty){
                                  if(double.parse(value)>1000){
                                    _priceEndController.text=1000.toString();
                                  }
                                  provider.setPriceEnd(double.parse(_priceEndController.text.trim()));
                                }
                              },
                              controller: _priceEndController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.5
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: '1000 ${'JOD'.tr()}',
                                // If  you are using latest version of flutter then lable text and hint text shown like this
                                // if you r using flutter less then 1.20.* then maybe this is not working properly
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                            ),
                          ),
                        ],
                      ),
                      /*RangeSlider(
                    values: provider.price,
                    max: 1000,
                    divisions: 1,

                    labels: RangeLabels(
                      provider.price.start.round().toString(),
                      provider.price.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {

                        provider.setPriceRange(values);

                      });
                    },
                  ),*/
                      const SizedBox(height: 15,),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text'.tr();
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: (){
                          showCityDialog(true);
                        },
                        controller: _departureController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0.5
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: 'Departure Destination'.tr(),
                          // If  you are using latest version of flutter then lable text and hint text shown like this
                          // if you r using flutter less then 1.20.* then maybe this is not working properly
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      const SizedBox(height: 15,),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text'.tr();
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: (){
                          showCityDialog(false);
                        },
                        controller: _arrivalController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0.5
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: 'Arrival Destination'.tr(),
                          // If  you are using latest version of flutter then lable text and hint text shown like this
                          // if you r using flutter less then 1.20.* then maybe this is not working properly
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      const SizedBox(height: 15,),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text'.tr();
                          }
                          return null;
                        },
                        readOnly: true,
                        onTap: ()async{
                          final range =await showDateRangePicker(
                            context: context,

                            currentDate: DateTime.now(),
                            initialDateRange: DateTimeRange(start: provider.startDate, end: provider.endDate),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2050),
                          );
                          if (range != null) {
                            provider.setDateStart(range.start);
                            provider.setDateEnd(range.end);
                            _dateController.text='${df.format(range.start)} - ${df.format(range.end)}';

                          }
                          /*final range = await showDialog(
                        context: context,
                        builder: (context) => Container(
                          color: Colors.white,
                          child: dp.RangePicker(
                            firstDate: DateTime.now(),
                            selectedPeriod: dp.DatePeriod(provider.startDate,provider.endDate),
                            lastDate: DateTime.now().add(Duration(days: 365)),

                            onChanged: (range){
                              provider.setDateStart(range.start);
                              provider.setDateEnd(range.end);
                              _dateController.text='${df.format(range.start)} - ${df.format(range.end)}';
                            },
                          ),
                        )
                      );*/
                          /*if (range != null) {
                        provider.setDateStart(range.start);
                        provider.setDateEnd(range.end);
                        _dateController.text='${df.format(range.start)} - ${df.format(range.end)}';

                      }*/
                          /*showCustomDateRangePicker(
                        context,
                        dismissible: true,
                        minimumDate: DateTime.now().subtract(const Duration(days: 30)),
                        maximumDate: DateTime.now().add(const Duration(days: 30)),
                        endDate: provider.endDate,
                        startDate: provider.startDate,
                        backgroundColor: Colors.white,
                        primaryColor: Colors.green,
                        onApplyClick: (start, end) {
                          provider.setDateStart(start);
                          provider.setDateEnd(end);
                          _dateController.text='${df.format(start)} - ${df.format(end)}';
                        },
                        onCancelClick: () {

                        },
                      );*/
                        },
                        controller: _dateController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0.5
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: 'Date'.tr(),
                          // If  you are using latest version of flutter then lable text and hint text shown like this
                          // if you r using flutter less then 1.20.* then maybe this is not working properly
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text'.tr();
                                }
                                return null;
                              },
                              readOnly: true,
                              onTap: () async {
                                final result = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(provider.startDate),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      );
                                    }
                                );
                                if (result != null) {
                                  setState(() {

                                    DateTime dateTime = provider.startTime;
                                    provider.setDateStart(DateTime(dateTime.year, dateTime.month, dateTime.day, result.hour, result.minute));

                                    _timeStartController.text=tf.format(provider.startTime);

                                  });


                                }
                              },
                              controller: _timeStartController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.5
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'Start Time'.tr(),
                                // If  you are using latest version of flutter then lable text and hint text shown like this
                                // if you r using flutter less then 1.20.* then maybe this is not working properly
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text'.tr();
                                }
                                return null;
                              },
                              readOnly: true,
                              onTap: () async {
                                final result = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(provider.endDate),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.dark(),
                                        child: child!,
                                      );
                                    }
                                );
                                if (result != null) {
                                  setState(() {

                                    DateTime dateTime = provider.endDate;
                                    provider.setDateStart(DateTime(dateTime.year, dateTime.month, dateTime.day, result.hour, result.minute));

                                    _timeEndController.text=tf.format(provider.endDate);

                                  });


                                }
                              },
                              controller: _timeEndController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent,
                                      width: 0.5
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'End Time'.tr(),
                                // If  you are using latest version of flutter then lable text and hint text shown like this
                                // if you r using flutter less then 1.20.* then maybe this is not working properly
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 15,),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(7)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10,0,15,0),
                          child: DropdownButton<String>(
                            value: selectedGender,
                            icon: const Icon(Icons.arrow_drop_down,color: Colors.black),
                            elevation: 16,
                            isExpanded: true,
                            underline: Container(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedGender = value!;
                                if(selectedGender==genders.first){
                                  provider.setGender('Male');
                                }
                                else if(selectedGender==genders[1]){
                                  provider.setGender('Female');
                                }
                                else{
                                  provider.setGender('Both');
                                }
                              });
                            },
                            items: genders.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,

                                child: Text(value,style: const TextStyle(color:  Colors.black, ),),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  CheckboxListTile(
                    title: Text('All Rides'.tr()),
                    value: provider.allRides,
                    onChanged: (bool? value){
                      provider.setAllRides(value!);
                    },
                  ),
                  const SizedBox(height: 15,),
                  Center(
                    child: InkWell(
                      onTap: ()async{


                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text('Search'.tr(),style: TextStyle(fontSize:16,color: Colors.white),),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> showCityDialog(bool departure){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context,setState){
              return Dialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                insetAnimationDuration: const Duration(seconds: 1),
                insetAnimationCurve: Curves.fastOutSlowIn,
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(


                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Search'.tr(),
                              // If  you are using latest version of flutter then lable text and hint text shown like this
                              // if you r using flutter less then 1.20.* then maybe this is not working properly
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              leading: Icon(Icons.error),
                              title: Text('No Data Found'.tr()),
                            );
                          },
                          suggestionsCallback: (pattern) async {

                            List<CityModel> search=[];
                            await FirebaseFirestore.instance
                                .collection('cities')
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                CityModel model=CityModel.fromMap(data, doc.reference.id);
                                if (model.name.contains(pattern))
                                  search.add(model);
                              });
                            });

                            return search;
                          },
                          itemBuilder: (context, CityModel suggestion) {
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(suggestion.name.tr()),
                            );
                          },
                          onSuggestionSelected: (CityModel suggestion) {
                            //_countryController.text=suggestion.name;
                            Navigator.pop(context);

                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('cities').snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data!.size==0){
                              return Center(
                                  child: Text('No Data Found'.tr(),style: TextStyle(color: Colors.black))
                              );

                            }

                            return ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: ListTile(
                                    onTap: (){
                                      Navigator.pop(context);
                                      showNeighbourDialog(CityModel.fromMap(data, document.reference.id),departure);



                                    },
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text('${data['name']}'.tr(),style: const TextStyle(color: Colors.black),),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Future<void> showNeighbourDialog(CityModel city,bool departure){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context,setState){
              return Dialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                insetAnimationDuration: const Duration(seconds: 1),
                insetAnimationCurve: Curves.fastOutSlowIn,
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(


                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Search'.tr(),
                              // If  you are using latest version of flutter then lable text and hint text shown like this
                              // if you r using flutter less then 1.20.* then maybe this is not working properly
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              leading: Icon(Icons.error),
                              title: Text('No Data Found'.tr()),
                            );
                          },
                          suggestionsCallback: (pattern) async {

                            List<CityModel> search=[];
                            await FirebaseFirestore.instance
                                .collection('cities').doc(city.id).collection('neighborhood')
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                CityModel model=CityModel.fromMap(data, doc.reference.id);
                                if (model.name.contains(pattern))
                                  search.add(model);
                              });
                            });

                            return search;
                          },
                          itemBuilder: (context, CityModel suggestion) {
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(suggestion.name.tr()),
                            );
                          },
                          onSuggestionSelected: (CityModel suggestion) {
                            final provider = Provider.of<FilterProvider>(context, listen: false);
                            if(departure){
                              provider.setDeparture('${city.name}:${suggestion.name}');
                              _departureController.text='${city.name.tr()} ${'to'.tr()} ${suggestion.name.toString().tr()}';
                            }
                            else{
                              provider.setArrival('${city.name}:${suggestion.name}');
                              _arrivalController.text='${city.name.tr()} ${'to'.tr()} ${suggestion.name.toString().tr()}';
                            }
                            Navigator.pop(context);

                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('cities').doc(city.id).collection('neighborhood').snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data!.size==0){
                              return Center(
                                  child: Text('No Data Found'.tr(),style: TextStyle(color: Colors.black))
                              );

                            }

                            return ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: ListTile(
                                    onTap: (){
                                      final provider = Provider.of<FilterProvider>(context, listen: false);
                                      setState(() {
                                        if(departure){

                                          _departureController.text='${city.name.tr()} ${'to'.tr()} ${data['name'].toString().tr()}';
                                          provider.setDeparture('${city.name}:${data['name']}');
                                        }
                                        else{
                                          provider.setArrival('${city.name}:${data['name']}');
                                          _arrivalController.text='${city.name.tr()} ${'to'.tr()} ${data['name'].toString().tr()}';
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text('${data['name']}'.tr(),style: const TextStyle(color: Colors.black),),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:wedeliver_business/common/LoadingButton.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/router/paths/OrderListPath.dart';
import 'package:wedeliver_business/services/api.dart';
import 'package:wedeliver_business/services/helpers.dart';
import 'package:wedeliver_business/state/appState.dart';

class NewOrderScreen extends StatefulWidget {
  AppState _appState;

  NewOrderScreen(this._appState);

  @override
  _NewOrderScreen createState() => _NewOrderScreen();
}

class _NewOrderScreen extends State<NewOrderScreen> {
  String branchValue = 'Branch One';
  int _update = 0;
  dynamic _cost;
  bool _showExtraFields = false;
  bool _placingOrder = false;
  bool _searchingCustomer = false;
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var form = {
    'branches': InputField(),
    'timeslots': InputField(),
    'package_sizes': InputField(),
    'fragile': InputField.value(true),
    'liquid': InputField.value(true),
    'mobile': InputField(),
    'name': InputField.hidden(),
    'area': InputField(),
    'address_line': InputField.hidden(),
    'delivery_payer': InputField(),
    'order_price': InputField(),
  };

  Widget pickupSelect() {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: form['branches'].options.length > 0
                ? DropdownButtonFormField<String>(
                    value: form['branches'].value,
                    decoration:
                        customInputDecoration(prefixIcon: Icons.location_pin
                            // labelText: 'Branch'
                            ),
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                    iconSize: 20,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    // underline: Container(height: 0),
                    onChanged: (String newValue) {
                      setState(() {
                        form['branches'].value = newValue;
                      });
                      getCost();
                    },
                    items: form['branches']
                        .options
                        .map<DropdownMenuItem<String>>((map) {
                      return DropdownMenuItem(
                        child: Text(map['name']),
                        value: map['id'].toString(),
                      );
                    }).toList())
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  double totalCOD() {
    var deliveryCost = deliverCost();
    var orderPrice = form['order_price'].controller.text;
    var deliveryPayer = form['delivery_payer'].value;
    if (deliveryPayer == 'Customer') {
      return (orderPrice.isEmpty ? 0 : double.parse(orderPrice)) + deliveryCost;
    } else if (deliveryPayer == 'Me') {
      return (orderPrice.isEmpty ? 0 : double.parse(orderPrice));
    }
    return 0;
  }

  double deliverCost() {
    var timeslot = form['timeslots']?.value;
    if (timeslot == null || _cost == null) {
      return 0;
    }
    var totalBySlot = _cost['total_by_slot']
        .where((tos) => tos['id'].toString() == timeslot)
        .toList();
    if (totalBySlot.length > 0) {
      return totalBySlot[0]['total'];
    }
    return 0;
  }

  Future<dynamic> placeOrder(Map<String, dynamic> params) async {
    var result = await call(
        url: '/orders/create_express_order', data: params, method: 'POST');

    this.setState(() {
      _placingOrder = false;
    });

    return result;
  }

  Widget placeOrderInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        color: GREY_COLOR,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              getTranslated(context, 'your_delivery_info'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      deliverCost().toString(),
                      style: TextStyle(
                        fontSize: 22,
                        color: PURPLE_COLOR,
                      ),
                    ),
                    Text(getTranslated(context, 'delivery_cost'),
                        style: TextStyle(color: Colors.grey[600]))
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      totalCOD().toString(),
                      style: TextStyle(
                        fontSize: 22,
                        color: PURPLE_COLOR,
                      ),
                    ),
                    Text(getTranslated(context, 'total_cdd'),
                        style: TextStyle(color: Colors.grey[600]))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Text(
                _cost == null
                    ? getTranslated(context, 'no_information')
                    : _cost['eta_note'],
                style: TextStyle(
                  fontSize: 22,
                  color: PURPLE_COLOR,
                ),
              ),
              Text(
                getTranslated(context, 'eta'),
                style: TextStyle(color: Colors.grey[600]),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: LoadingButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      )),
                      elevation: MaterialStateProperty.all(0),
                      backgroundColor: MaterialStateProperty.all(
                        PURPLE_COLOR,
                      ),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20)),
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 24)),
                    ),
                    loading: _placingOrder,
                    label: getTranslated(context, 'place_order'),
                    onPressed: (value) {
                      if (_formKey.currentState.validate()) {
                        print('submitting order');
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }

                        Map<String, dynamic> order = {
                          'business_branch_id': form['branches'].value,
                          'order_price': form['order_price'].controller.text,
                          'dropoff_address_line':
                              form['address_line'].controller.text,
                          'dropoff_area_id': form['area'].value,
                          'delivery_cost_on':
                              form['delivery_payer'].value == 'Me'
                                  ? 'business'
                                  : 'customer',
                          'customer_id': form['name'].value,
                          'cod_payment_method': 'cash',
                          'delivery_type': 'Express',
                          'customer_name': form['name'].controller.text,
                          'customer_mobile': form['mobile'].controller.text,
                          'is_cod_needed': 1,
                          /*'parcels': jsonEncode([
                            {
                              "package_size_id": form['package_sizes'].value,
                              "is_fragile": form['fragile'].value,
                              "is_liquid": form['liquid'].value
                            }
                          ]),*/
                          'slot_id': form['timeslots'].value,
                          'delivery_cost_split_percentage': 0
                        };

                        this.setState(() {
                          _update += 1;
                          _placingOrder = true;
                        });

                        var response;
                        runZonedGuarded(() async {
                          response = await placeOrder(order);
                          widget._appState.route = OrderListPath();

                          // print('test $response');
                        }, (Object error, StackTrace stack) {
                          this.setState(() {
                            _placingOrder = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.toString()),
                            ),
                          );
                        });
                      } else {
                        this.setState(() {
                          _update += 1;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget customRadio(
      {String label,
      List<dynamic> values,
      String defaultValue,
      ValueChanged onSelect}) {
    var selectedValue = (defaultValue != null && defaultValue.isNotEmpty)
        ? defaultValue
        : (values.length > 0 ? values[0]['id'] : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(label),
        ),
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: GREY_COLOR,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: CustomRadioButton(
            enableShape: false,
            defaultSelected: selectedValue,
            unSelectedBorderColor: Colors.transparent,
            selectedBorderColor: Colors.transparent,
            unSelectedColor: Colors.transparent,
            elevation: 0,
            // absoluteZeroSpacing: true,
            buttonLables: values
                .map<String>(
                  (value) =>
                      value.runtimeType == String ? value : value['title'],
                )
                .toList(),
            buttonValues: values
                .map<String>(
                  (value) => value.runtimeType == String
                      ? value
                      : value['id'].toString(),
                )
                .toList(),
            radioButtonValue: onSelect,
            selectedColor: Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }

  InputDecoration customInputDecoration(
      {labelText, IconData prefixIcon, showSuffixIcon = false}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: const BorderRadius.all(
          const Radius.circular(8.0),
        ),
      ),
      labelText: labelText,
      filled: true,
      prefixIcon: (prefixIcon != null)
          ? Icon(
              prefixIcon,
              color: Theme.of(context).primaryColor,
            )
          : null,
      suffixIconConstraints: BoxConstraints(maxHeight: 15, maxWidth: 15),
      suffixIcon: showSuffixIcon
          ? SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            )
          : SizedBox.shrink(),
      fillColor: GREY_COLOR,
      contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        // borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  getBranches() {
    call(
      url: '/business/get_abstract_business_branches',
      method: 'GET',
      includeBID: true,
    ).then((value) {
      this.setState(() {
        form['branches'].options = value;
        form['branches'].value = value[0]['id'].toString();
      });
    });
  }

  getCost() {
    final areaId = form['area'].value;
    final branchId = form['branches'].value;
    if (areaId == null || branchId == null) {
      return;
    }
    call(url: '/orders/get_delivery_cost', method: 'GET', data: {
      'area_id': areaId,
      'business_branch_id': int.parse(branchId)
    }).then((value) {
      this.setState(() {
        _cost = value;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          /*action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),*/
        ),
      );
    });
  }

  getTimeSlots() {
    call(
      url: '/orders/get_active_delivery_slots_for_order',
      method: 'GET',
    ).then((value) {
      this.setState(() {
        form['timeslots'].options = value;
        form['timeslots'].value = value[0]['id'].toString();
      });
    });
  }

  getPackageSizes() {
    call(
      url: '/settings/get_abstract_packages_sizes',
      method: 'GET',
    ).then((value) {
      this.setState(() {
        form['package_sizes'].options = value;
        form['package_sizes'].value = value[0]['id'].toString();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getBranches();
    getTimeSlots();
    getPackageSizes();
  }

  @override
  void didUpdateWidget(covariant NewOrderScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: pickupSelect(),
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Wrap(
                    runSpacing: 10,
                    children: [
                      Text(
                        getTranslated(context, 'create_order'),
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              keyboardType:TextInputType.phone ,
                              controller: form['mobile'].controller,
                              decoration: customInputDecoration(
                                labelText: getTranslated(context, 'mobile'),
                                // showSuffixIcon: _searchingCustomer,
                              ),
                            ),
                            debounceDuration: Duration(milliseconds: 500),
                            hideOnLoading: true,
                            hideOnEmpty: true,
                            suggestionsCallback: (pattern) async {
                              var result = [];
                              if (pattern.isEmpty || pattern.length < 3) {
                                print('Query needs to be at least 3 chars');
                                return Future.value([]);
                              }
                              print('search for $pattern');
                              result = await call(
                                  url: '/business/get_all_customers',
                                  method: 'GET',
                                  data: {'mobile': pattern});

                              if (result.isEmpty) {
                                result.add({'name': 'New Customer'});
                              }

                              return result;
                            },
                            // loadingBuilder: (a) => SizedBox.shrink(),
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion['name']),
                                subtitle: (suggestion['mobile'] != null)
                                    ? Text(suggestion['mobile'])
                                    : null,
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              form['mobile'].controller.text =
                                  suggestion['mobile'];
                              form['name'].controller.text =
                                  suggestion['id'] != null
                                      ? suggestion['name']
                                      : null;
                              form['name'].value = suggestion['id'];
                              setState(() {
                                form['name'].show = true;
                                form['name'].enabled =
                                    form['name'].value == null;
                              });
                            },
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxHeight: form['mobile'].hasError ? 23 : 0),
                            child: TextFormField(
                              readOnly: true,
                              controller: form['mobile'].controller,
                              style: TextStyle(color: Colors.transparent),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  form['mobile'].hasError = true;
                                  return getTranslated(context, 'mobile_msj');
                                }
                                form['mobile'].hasError = false;
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                      form['name'].show
                          ? TextFormField(
                              enabled: form['name'].enabled,
                              controller: form['name'].controller,
                              validator: (String value) {
                                if (value == null || value.isEmpty) {
                                  return getTranslated(context, 'name_msj');
                                }
                                return null;
                              },
                              decoration:
                                  customInputDecoration(labelText: 'Name'),
                            )
                          : SizedBox.shrink(),
                      Column(
                        children: [
                          TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: form['area'].controller,
                              decoration: customInputDecoration(
                                labelText: getTranslated(context, 'area'),
                                // showSuffixIcon: form['area'].loading,
                              ),
                            ),
                            debounceDuration: Duration(milliseconds: 500),
                            hideOnLoading: true,
                            hideOnEmpty: true,
                            suggestionsCallback: (pattern) async {
                              var result = [];
                              if (pattern.isEmpty || pattern.length < 3) {
                                print('Query needs to be at least 3 chars');
                                return Future.value([]);
                              }
                              result = await call(
                                url:
                                    '/location/get_all_abstract_supported_areas',
                                method: 'GET',
                                data: {
                                  'search_text': pattern,
                                  'business_branch_id': form['branches'].value,
                                },
                                includeBID: true,
                              );
                              return result;
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion['name']),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              form['area'].controller.text = suggestion['name'];
                              form['area'].value = suggestion['id'];

                              setState(() {
                                form['address_line'].show = true;
                              });

                              getCost();
                            },
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxHeight: form['area'].hasError ? 23 : 0),
                            child: TextFormField(
                              readOnly: true,
                              controller: form['area'].controller,
                              style: TextStyle(color: Colors.transparent),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  form['area'].hasError = true;
                                  return getTranslated(context, 'area_msj');
                                }
                                form['area'].hasError = false;
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                      form['address_line'].show
                          ? TextFormField(
                              controller: form['address_line'].controller,
                              validator: (String value) {
                                if (value == null || value.isEmpty) {
                                  return getTranslated(
                                      context, 'address_line_msj');
                                }
                                return null;
                              },
                              decoration: customInputDecoration(
                                labelText:
                                    getTranslated(context, 'address_line'),
                              ),
                            )
                          : SizedBox.shrink(),
                      TextFormField(
                        controller: form['order_price'].controller,
                        onEditingComplete: () {
                          this.setState(() {
                            _update += 1;
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: customInputDecoration(
                          labelText: getTranslated(context, 'order_price'),
                        ),
                      ),
                      Visibility(
                        visible: form['timeslots'].options.length > 0,
                        child: customRadio(
                          label: getTranslated(context, 'delivery_timeslot'),
                          values: form['timeslots'].options,
                          defaultValue: form['timeslots'].value,
                          onSelect: (value) {
                            this.setState(() {
                              form['timeslots'].value = value;
                            });
                          },
                        ),
                      ),
                      customRadio(
                        label: getTranslated(context, 'who_will_pay'),
                        values: ["Me", "Customer"], //TODO solve translation
                        defaultValue: 'Me',
                        onSelect: (value) {
                          this.setState(() {
                            form['delivery_payer'].value = value;
                          });
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: GREY_COLOR,
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          maxLines: 6,
                          decoration: InputDecoration.collapsed(
                            hintText: getTranslated(context, 'write_note'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showExtraFields = !_showExtraFields;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                    'Show ${_showExtraFields ? 'less' : 'more'} options',
                                    //TODO solve translation
                                    style: TextStyle(fontSize: 18)),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(_showExtraFields
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down)
                              ],
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      _showExtraFields
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  customRadio(
                                    label:
                                        getTranslated(context, 'parcel_size'),
                                    values: form['package_sizes'].options,
                                    defaultValue: form['package_sizes'].value,
                                  ),
                                  CheckboxListTile(
                                    title:
                                        Text(getTranslated(context, 'fragile')),
                                    value: form['fragile'].value,
                                    onChanged: (newValue) {
                                      this.setState(() {
                                        form['fragile'].value = newValue;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                  CheckboxListTile(
                                    title:
                                        Text(getTranslated(context, 'liquid')),
                                    value: form['liquid'].value,
                                    onChanged: (newValue) {
                                      this.setState(() {
                                        form['liquid'].value = newValue;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                placeOrderInfo()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputField {
  TextEditingController controller = TextEditingController();
  bool enabled = true;
  bool loading = false;
  bool show = true;
  bool hasError = false;

  dynamic value;
  List<dynamic> options = [];

  InputField();

  InputField.hidden() : show = false;

  InputField.value(this.value);
}


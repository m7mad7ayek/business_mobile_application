import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wedeliver_business/common/LoadingButton.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/services/api.dart';
import 'package:wedeliver_business/services/helpers.dart';
import 'package:wedeliver_business/state/appState.dart';

class OrderItem extends StatefulWidget {
  final Map<String, dynamic> order;
  final List<dynamic> cancellationReasons;
  final Function onUpdate;

  const OrderItem(
      {Key key, this.order, this.cancellationReasons, this.onUpdate})
      : super(key: key);

  @override
  _OrderItem createState() => _OrderItem();
}

class _OrderItem extends State<OrderItem> {
  List<int> _cancelingOrder = [];

  Widget cardOption({
    IconData icon,
    String label,
    bool loading,
    Function onPress,
    bool disabled = false,
  }) {
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: disabled ? null : (!loading ? onPress : null),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: loading
                  ? SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
                height: 20,
                width: 20,
              )
                  : Icon(
                icon,
                color: Colors.grey,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var order = widget.order;
    Color backgroundColor = getStatusColor(status: order['order_status']).bg;
    Color borderColor = getStatusColor(status: order['order_status']).bc;
    Color foregroundColor = getStatusColor(status: order['order_status']).fc;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: GREY_COLOR,
      ),
      padding: EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 16, left: 10.0, right: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  order['show_content'] = order['show_content'] == null
                      ? true
                      : !order['show_content'];
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '# ${order['tracking_id']}',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Container(
                          padding:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                          child: Text(
                            order['order_status'],
                            style: TextStyle(color: foregroundColor),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: backgroundColor,
                              border: Border.all(color: borderColor)),
                        )
                      ],
                    ),
                    Stack(
                      children: [
                        Positioned(
                          top: 45,
                          left: 27.5,
                          child: Container(
                            width: 1,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.grey),
                          ),
                        ),
                        Column(
                          children: [
                            ListTile(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                  '${order['pickup_city_name']} ${order['pickup_area_name']}'),
                              subtitle: Text(
                                  getTranslated(context, "pickup_address")),
                              leading: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  // color: Colors,
                                ),
                                child: Icon(Icons.circle),
                              ),
                            ),
                            ListTile(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                  '${order['dropoff_city_name']} ${order['dropoff_area_name']}'),
                              subtitle: Text(
                                  getTranslated(context, "customer_address")),
                              leading: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey[350],
                                ),
                                child: Icon(Icons.flag),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: order['show_content'] == true,
            child: Column(
              children: [
                ListTile(
                  title: Text(order['customer_name']),
                  subtitle: Text(getTranslated(context, 'customer')),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    padding: EdgeInsets.all(8.0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[400],
                    ),
                    child: Text(getTranslated(context, 'pic')),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.grey[600],
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated(context, 'delivery_info')),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye),
                                  SizedBox(width: 6),
                                  Text(getTranslated(context, 'view')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(Icons.directions_car),
                      ),
                      Divider(
                        color: Colors.grey[600],
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated(context, 'other_info')),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye),
                                  SizedBox(width: 6),
                                  Text(getTranslated(context, 'view')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(Icons.article),
                      ),
                      Divider(
                        color: Colors.grey[600],
                      ),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getTranslated(context, 'notes')),
                            TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Icon(Icons.remove_red_eye),
                                  SizedBox(width: 6),
                                  Text(getTranslated(context, 'view')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(Icons.article_outlined),
                      ),
                      Divider(
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    cardOption(
                      icon: Icons.location_pin,
                      label: getTranslated(context, 'live_tracking'),
                      loading: false,
                      onPress: () {},
                    ),
                    cardOption(
                      icon: Icons.chat_bubble_outlined,
                      label: getTranslated(context, 'live_chat'),
                      loading: false,
                      onPress: () {},
                    ),
                    cardOption(
                      icon: Icons.edit_outlined,
                      label: getTranslated(context, 'edit'),
                      loading: false,
                      onPress: () {},
                    ),
                    cardOption(
                        icon: Icons.cancel_rounded,
                        label: getTranslated(context, 'cancel'),
                        disabled: order['order_status'] == 'Canceled',
                        loading: _cancelingOrder.contains(order['id']),
                        onPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              Map<String, dynamic> _selectedReason;
                              final GlobalKey<FormState> _formKey =
                              GlobalKey<FormState>();
                              TextEditingController notesController =
                              TextEditingController();
                              TextEditingController reasonController =
                              TextEditingController();
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text(
                                      "Cancel Order ${order['tracking_id']}", //TODO translation
                                    ),
                                    content: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButtonFormField(
                                            hint: Text(getTranslated(
                                                context, 'cancel_reason')),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              setState(() =>
                                              _selectedReason = value);
                                            },
                                            validator: (dynamic value) {
                                              if (value == null) {
                                                return getTranslated(context,
                                                    'cancel_reason_msj');
                                              }
                                              return null;
                                            },
                                            value: _selectedReason,
                                            items: widget.cancellationReasons
                                                .map((cr) {
                                              return DropdownMenuItem(
                                                child: Text(cr['description']),
                                                value: cr,
                                              );
                                            }).toList(),
                                          ),
                                          if (_selectedReason != null &&
                                              _selectedReason[
                                              'is_note_required'] ==
                                                  true)
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: GREY_COLOR,
                                                ),
                                                padding: EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  maxLines: 6,
                                                  controller: notesController,
                                                  validator: (String value) {
                                                    if (value.isEmpty) {
                                                      return getTranslated(
                                                          context,
                                                          'extra_info_msj');
                                                    }
                                                    return null;
                                                  },
                                                  decoration:
                                                  InputDecoration.collapsed(
                                                    hintText: getTranslated(
                                                        context,
                                                        'cancelling_extra_info_msj'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                            getTranslated(context, 'cancel')),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      LoadingButton(
                                        label: getTranslated(context, 'ok'),
                                        loading: _cancelingOrder
                                            .contains(order['id']),
                                        onPressed: (value) {
                                          if (!_formKey.currentState
                                              .validate()) {
                                            return;
                                          }
                                          var params = {
                                            'cancellation_reason_id':
                                            _selectedReason['id'],
                                            'cancellation_reason_note':
                                            notesController.text,
                                            'order_id': order['id']
                                          };
                                          _cancelingOrder.add(order['id']);
                                          setState(() {
                                            _cancelingOrder = _cancelingOrder;
                                          });
                                          // Navigator.of(context).pop();
                                          var response;
                                          runZonedGuarded(() async {
                                            response = await call(
                                                url: '/orders/cancel',
                                                method: 'POST',
                                                data: params);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  response['message'],
                                                ),
                                              ),
                                            );

                                            _cancelingOrder.remove(order['id']);

                                            setState(() {
                                              _cancelingOrder = _cancelingOrder;
                                            });

                                            Navigator.of(context).pop();
                                            widget.onUpdate();

                                            print('test $response');
                                          }, (Object error, StackTrace stack) {
                                            _cancelingOrder.remove(order['id']);

                                            setState(() {
                                              _cancelingOrder = _cancelingOrder;
                                            });
                                            final scaffold =
                                            ScaffoldMessenger.of(context);
                                            scaffold.showSnackBar(
                                              SnackBar(
                                                content: Text(error.toString()),
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OrderListScreen extends StatelessWidget {
  // final List<Order> orders;
  AppState _appState;

  // RemoteConfig remoteConfig = RemoteConfig.instance;

  // Future getRemoteConfig() async {
  //   bool updated = await remoteConfig.fetchAndActivate();
  //   if (updated) {
  //     // the config has been updated, new parameter values are available.
  //   } else {
  //     // the config values were previously updated.
  //   }
  //  var x = remoteConfig.getString('force_update');
  //   print("RemoteConfig: "+x);
  //  return x;
  // }

  OrderListScreen(this._appState);

  Future<Map<String, dynamic>> getData() async {
    var orders = await call(
        url: '/orders/get_all_orders', method: 'GET', includeBID: true);
    var cancellationReasons = await call(
        url: '/settings/get_abstract_cancellation_reasons', method: 'GET');

    Set<String> statuses = Set();
    Set<String> branches = Set();

    statuses.add('All');
    branches.add('All');
    Map counts = {'Total': 0, 'Ongoing': 0, 'Delivered': 0, 'Failed': 0};
    orders.forEach((element) {
      statuses.add(element['order_status']);
      branches.add(element['business_branch_name']);
      counts['Total']++;
      switch (element['order_status']) {
        case 'Delivered':
          counts['Delivered']++;
          break;
        case 'Delivery Failed':
        case 'Picking Up Failed':
          counts['Failed']++;
          break;
        case 'Assigned for Delivery':
        case 'Delivering':
        case 'Pending Delivery':
        case 'Picked Up':
        case 'Picking Up':
          counts['Ongoing']++;
          break;
      }
    });
    Map<String, dynamic> output = {
      'cancellation_reasons': cancellationReasons,
      'orders': orders,
      'meta': {
        'counts': counts,
        'branches': branches.toList(),
        'statuses': statuses.toList()
      }
    };

    return output;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                AppBar(
                  title: Text(getTranslated(context, 'my_orders')),
                ),
                Expanded(
                  child: CardListSkeleton(
                    style: SkeletonStyle(
                      theme: SkeletonTheme.Light,
                      isShowAvatar: false,
                      barCount: 5,
                    ),
                  ),
                ),
              ],
            );
          } else {
            if (snapshot.hasError)
              return Center(
                  child: Text('Error: ${snapshot.error}')); // TODO translation
            else
              return OrderPage(
                data: snapshot.data,
                onRefresh: getData,
              ); // snapshot.data  :- get your object which is pass from your downloadData() function
          }
        },
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function onRefresh;

  const OrderPage({Key key, @required this.data, this.onRefresh})
      : super(key: key);

  @override
  _OrderPage createState() => _OrderPage();
}

class _OrderPage extends State<OrderPage> {
  List<dynamic> cancellationReasons;
  String searchValue;
  String statusValue;
  String pickupBranchValue;
  String rangeOfDatesValue;

  bool _filteringOrders = false;
  List filteredOrders = [];

  Timer bounceTime;

  // set up the AlertDialog
  // List orders = <Map<String, dynamic>>[];
  // _OrderPage(): this.statusValue = widget.data['meta']['statues'][0];
  @override
  initState() {
    super.initState();
    onRefresh(data: widget.data, waiter: false);
  }

  onRefresh({Map data, bool waiter = true}) {
    setState(() {
      cancellationReasons = data['cancellation_reasons'] ?? [];
      searchValue = searchValue ?? '';
      statusValue = statusValue ?? data['meta']['statuses'][0];
      pickupBranchValue = pickupBranchValue ?? data['meta']['branches'][0];
      rangeOfDatesValue = rangeOfDatesValue ?? 'Last 30 days';
    });
    filterOrders(orders: data['orders'], waiter: waiter);
  }

  void filterOrders({List orders, bool waiter = true}) async {
    if (waiter == true) {
      this.setState(() {
        _filteringOrders = true;
      });
      await Future.delayed(Duration(milliseconds: 500));
    }

    DateTime from;
    DateTime date = new DateTime.now();
    switch (rangeOfDatesValue) {
      case 'Last 30 days':
        from = new DateTime(date.year, date.month, date.day - 30);
        break;
      case 'Last 60 days':
        from = new DateTime(date.year, date.month, date.day - 60);
        break;
      case 'Last 90 days':
        from = new DateTime(date.year, date.month, date.day - 90);
        break;
    }

    List _orders = (orders ?? widget.data['orders']).where((order) {
      return pickupBranchValue == 'All' ||
          order['business_branch_name'] == pickupBranchValue;
    }).where((order) {
      return statusValue == 'All' || order['order_status'] == statusValue;
    }).where((order) {
      return searchValue == null ||
          searchValue.isEmpty ||
          order['tracking_id'].contains(searchValue) ||
          order['customer_name'].contains(searchValue);
    }).where((order) {
      if (rangeOfDatesValue == 'All') {
        return true;
      }

      DateTime orderCreationDateTime =
      new DateFormat("yyyy-MM-dd HH:mm").parse(order['creation']);

      return orderCreationDateTime.compareTo(from) >= 0;
    }).toList();
    setState(() {
      filteredOrders = _orders;
      _filteringOrders = false;
    });
  }

  Widget dropdown(
      {String label,
        String defaultValue,
        List<String> items,
        Function(String) onChanged,
        bool withConstLabelName = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[250], fontSize: 12),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: 30),
          child: DropdownButton<String>(
            value: defaultValue,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            iconSize: 16,
            elevation: 16,
            style: TextStyle(fontSize: 17, color: Colors.black),
            underline: SizedBox.shrink(),
            onChanged: onChanged,
            items: items
                .map<DropdownMenuItem<String>>((String value) =>
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    withConstLabelName
                        ? getTranslated(context,
                        value.trim().replaceAll(" ", "_").toLowerCase())
                        : value,
                    style: TextStyle(fontSize: 14),
                  ),
                ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget filterSection() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              constraints: BoxConstraints(maxHeight: 45),
              child: TextField(
                onChanged: (String value) async {
                  setState(() {

                    searchValue = value.toUpperCase();
                  });
                  if (bounceTime != null) {
                    bounceTime.cancel();
                  }
                  bounceTime = Timer(Duration(milliseconds: 500), () {
                    print('search for $value');
                    filterOrders();
                  });
                },
                decoration: InputDecoration(
                  // border: InputBorder.none,
                  fillColor: GREY_COLOR,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(color: Colors.grey[300], width: 0.5),
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: new Icon(Icons.search),
                  contentPadding: EdgeInsets.only(top: 10),
                  hintText: getTranslated(context, 'search_msj'),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  dropdown(
                      label: getTranslated(context, 'status'),
                      defaultValue: statusValue,
                      items: widget.data['meta']['statuses'],
                      onChanged: (String value) {
                        print(value);
                        setState(() {
                          statusValue = value;
                        });
                        filterOrders();
                      }),
                  SizedBox(width: 15,),
                  dropdown(
                      label: getTranslated(context, 'pickup_branch'),
                      defaultValue: pickupBranchValue,
                      items: widget.data['meta']['branches'],
                      onChanged: (String value) {
                        setState(() {
                          pickupBranchValue = value;
                        });
                        filterOrders();
                      }),
                  SizedBox(width: 15,),
                  dropdown(
                      label: getTranslated(context, 'range_of_dates'),
                      defaultValue: rangeOfDatesValue,
                      items: ['Last 30 days', 'Last 60 days', 'Last 90 days'],
                      onChanged: (String value) {
                        setState(() {
                          rangeOfDatesValue = value;
                        });
                        filterOrders();
                      },withConstLabelName: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> statItem({@required String label, bool last = false}) {
    return [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.data['meta']['counts'][label].toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Text(getLabelString(label)),
          ],
        ),
      ),
      if (last == false)
        Container(height: 30, child: VerticalDivider(color: Colors.grey)),
    ];
  }

  Widget topStats() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...statItem(label: 'Total'),
          ...statItem(label: 'Ongoing'),
          ...statItem(label: 'Delivered'),
          ...statItem(label: 'Failed', last: true),
        ],
      ),
    );
  }

  Future<bool> onUpdate() async {
    Map data = await widget.onRefresh();
    onRefresh(data: data);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await onUpdate();
      },
      child: Container(
        color: Colors.white,
        child: CustomScrollView(physics: ScrollPhysics(), slivers: [
          SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              // title: Text('My Orders'),
              flexibleSpace: new FlexibleSpaceBar(
                  title: new Text(""),
                  background: Column(
                    children: [
                      AppBar(
                        title: Text(getTranslated(context, 'my_orders')),
                      ),
                      Container(
                        // margin: EdgeInsets.only(top: 10),
                        color: GREY_COLOR,
                        child: topStats(),
                      )
                    ],
                  )),
              expandedHeight: 280.0,
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(86.0),
                  // here the desired height
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    child: filterSection(),
                  ))),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 40.0),
            sliver: _filteringOrders
                ? SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                ))
                : filteredOrders.isEmpty
                ? SliverToBoxAdapter(
                child: Center(
                  child: Text(getTranslated(context, 'no_order')),
                ))
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return OrderItem(
                    order: filteredOrders[index],
                    cancellationReasons: cancellationReasons,
                    onUpdate: onUpdate,
                  );
                },
                childCount: filteredOrders.length,
              ),
            ),
          ),
        ] /*Container(
            color: Colors.grey[300],
            child: Column(
              children: [
                topStats(),
                Container(
                  // color: Colors.white,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: filterSection(),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return OrderItem(
                        order: filteredOrders[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),*/
        ),
      ),
    );
  }

  // {'Total': 0, 'Ongoing': 0, 'Delivered': 0, 'Failed': 0};
  String getLabelString(String label) {
    String value = "";
    switch (label) {
      case 'Total':
        value = getTranslated(context, "total");
        break;
      case 'Ongoing':
        value = getTranslated(context, "ongoing");
        break;
      case 'Delivered':
        value = getTranslated(context, "delivered");
        break;
      case 'Failed':
        value = getTranslated(context, "failed");
        break;
    }
    return value;
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedeliver_business/localization/language_constant.dart';
import 'package:wedeliver_business/services/api.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreen createState() => _WalletScreen();
}

class _WalletScreen extends State<WalletScreen> {
  Map<String, dynamic> cachedStats;

  Widget statBlock(
      {@required String label, dynamic value, String description}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                if (description != null && description.isNotEmpty)
                  MyTooltip(
                    message: description,
                    child: IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {},
                    ),
                  )
              ],
            ),
            Row(
              children: [
                Icon(Icons.show_chart),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '$value',
                  style: TextStyle(fontSize: 25),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getStats() async {
    if (cachedStats != null) {
      return cachedStats;
    }
    var orders = await call(
      url: '/orders/get_orders_stats',
      method: 'GET',
      data: {'party_type': 'business'},
      includeBID: 'party_id',
    );

    return orders['stats'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'wallet')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Map<String, dynamic> _stats = await getStats();
          setState(() {
            cachedStats = _stats;
          });
        },
        child: FutureBuilder(
          future: getStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CardListSkeleton(
                style: SkeletonStyle(
                  theme: SkeletonTheme.Light,
                  isShowAvatar: false,
                  barCount: 2,
                ),
              );
            } else {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              else
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Wrap(
                      runSpacing: 8,
                      children: [
                        statBlock(
                            label: getTranslated(context, 'balance'),
                            value: snapshot.data['current_balance'],
                            description:
                                getTranslated(context, 'balance_desc')),
                        statBlock(
                          label: getTranslated(context, 'payments'),
                          value: snapshot.data['payments_total'],
                          description: getTranslated(context, 'payments_desc'),
                        ),
                        statBlock(
                          label: getTranslated(context, 'incomplete_orders'),
                          value: snapshot.data['pending_orders_count'],
                          description:
                              getTranslated(context, 'incomplete_orders_desc'),
                        ),
                        statBlock(
                          label: getTranslated(context, 'completed_orders'),
                          value: snapshot.data['delivered_orders_count'],
                          description:
                              getTranslated(context, 'completed_orders_desc'),
                        ),
                        TextButton(
                          onPressed: () async {
                            const url =
                                'https://business.wedeliverspace.dev/wallet';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text(getTranslated(context, 'more_details')),
                        )
                      ],
                    ),
                  ),
                ); // snapshot.data  :- get your object which is pass from your downloadData() function
            }
          },
        ),
      ),
    );
  }
}

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  MyTooltip({@required this.message, @required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        // todo: dose not working
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}

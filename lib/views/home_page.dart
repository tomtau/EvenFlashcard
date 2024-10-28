import 'dart:async';
import 'package:demo_ai_even/ble_manager.dart';
import 'package:demo_ai_even/services/evenai.dart';
import 'package:demo_ai_even/views/even_list_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? scanTimer;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    BleManager.get().setMethodCallHandler();
    BleManager.get().startListening();
    BleManager.get().onStatusChanged = _refreshPage;
  }

  void _refreshPage() {
    setState(() { });
  }

  Future<void> _startScan() async {
    setState(() {
      isScanning = true;
    });
    await BleManager.get().startScan();
    scanTimer?.cancel();
    scanTimer = Timer(Duration(seconds: 15), () { // todo
      _stopScan();
    });
  }

  Future<void> _stopScan() async {
    if (isScanning) {
      await BleManager.get().stopScan();
      setState(() {
        isScanning = false;
      });
    }
  }

  Widget blePairedList() {
    return  Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 5),
        itemCount: BleManager.get().getPairedGlasses().length,
        itemBuilder: (context, index) {
          final glasses = BleManager.get().getPairedGlasses()[index];
          return GestureDetector(
            onTap: () async {
              String channelNumber = glasses['channelNumber']!;
              await BleManager.get().connectToGlasses("Pair_$channelNumber");
            },
            child: Container(
              height: 72,
              padding: EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pair: ${glasses['channelNumber']}'),
                      Text('Left: ${glasses['leftDeviceName']} \nRight: ${glasses['rightDeviceName']}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Even AI Demo'),
        backgroundColor: Colors.white.withOpacity(0.8),
      ),
      backgroundColor: Colors.white.withOpacity(0.9),
      body: Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 44), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                if (BleManager.get().getConnectionStatus() == 'Not connected') {
                  _startScan();
                }
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(BleManager.get().getConnectionStatus(), style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            if (BleManager.get().getConnectionStatus() == 'Not connected') 
              blePairedList(),

            if (BleManager.get().isConnected)
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    // todo
                    print("To AI History List...");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EvenAIListPage()),
                    );
                  },
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: StreamBuilder<String>(
                        stream: EvenAI.textStream,
                        initialData: "Press and hold left TouchBar to engage Even AI.",
                        builder: (context, snapshot) {
                          return Obx(() {
                            return EvenAI.isEvenAISyncing.value 
                              ? const SizedBox(
                                    width: 50, 
                                    height: 50, 
                                    child: CircularProgressIndicator(), 
                                  ) // Color(0xFFFEF991)
                              : Text(
                                  snapshot.data ?? "Loading...",
                                  style: TextStyle(fontSize: 14, color: BleManager.get().isConnected ? Colors.black : Colors.grey.withOpacity(0.5)),
                                );
                              }
                          );
                        })
                    )
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    isScanning = false;
    BleManager.get().onStatusChanged = null;
    super.dispose();
  }
}

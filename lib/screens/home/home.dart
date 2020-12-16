import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visual_sorter/constants.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:visual_sorter/screens/privacy_policy/privacy_policy.dart';
import 'package:random_color/random_color.dart';

RandomColor _randomColor = RandomColor();
var size = initArraySize;
List<int> arr = _getRandomIntegerList(size);
bool isAlgorithmRunning = false;
int _selectedIndex = 0;
int index = 0;
double hieghtUni, widthUni;
String timeC = "00.00.00.00";
var arrays = "";
List<int> displayArr = arr;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      isAlgorithmRunning = false;
      arr = _getRandomIntegerList(size);
    });
  }

  @override
  Widget build(BuildContext context) {
//async update method to keep the body of recursive algorithms cleaner.
    _updateArrayWithDelay(List<int> updatedArr) async {
      await Future.delayed(const Duration(milliseconds: time), () {
        setState(() {
          displayArr = updatedArr;
          arr = List.from(updatedArr);
        });
      });
    }

    void _setAlgorithmRunningState(bool state) {
      setState(() {
        isAlgorithmRunning = state;
      });
    }

    _bubbleSortVisualiser(arr) async {
      List<int> bubbleArr = List.from(arr);
      for (int i = 0; i < bubbleArr.length - 1; i++) {
        for (int j = 0; j < bubbleArr.length - 1 - i; j++) {
          int temp;
          if (bubbleArr[j] < bubbleArr[j + 1]) {
            temp = bubbleArr[j];
            bubbleArr[j] = bubbleArr[j + 1];
            bubbleArr[j + 1] = temp;
            //Every time arr changes setState() is called to visualise the changing array.

            await _updateArrayWithDelay(bubbleArr);
          }
        }
      }
    }

    //helper function to merge the array for merge sort
    merge(List<int> mergeArr, int low, int mid, int high) async {
      int i, j, k;
      int n1 = mid - low + 1;
      int n2 = high - mid;

      /* create temp arrays */
      List<int> L = [], R = [];

      /* Copy data to temp arrays L[] and R[] */
      for (i = 0; i < n1; i++)
        L.add(mergeArr[low + i]); //L[i] = mergeArr[low + i];
      for (j = 0; j < n2; j++)
        R.add(mergeArr[mid + 1 + j]); //R[j] = mergeArr[mid + 1 + j];

      i = 0;
      j = 0;
      k = low;
      while (i < n1 && j < n2) {
        if (L[i] <= R[j]) {
          mergeArr[k] = L[i];
          i++;
        } else {
          mergeArr[k] = R[j];
          j++;
        }
        await _updateArrayWithDelay(mergeArr);
        k++;
      }

      while (i < n1) {
        mergeArr[k] = L[i];
        i++;
        k++;
      }

      while (j < n2) {
        mergeArr[k] = R[j];
        j++;
        k++;
      }
    }

    Future<int> _partition(List<int> quickArr, int low, int high) async {
      int pivot = quickArr[high];
      int i = (low - 1);
      int temp;
      for (int j = low; j <= high - 1; j++) {
        if (quickArr[j] < pivot) {
          i++;
          temp = quickArr[i];
          quickArr[i] = quickArr[j];
          quickArr[j] = temp;
          await _updateArrayWithDelay(quickArr);
        }
      }
      temp = quickArr[i + 1];
      quickArr[i + 1] = quickArr[high];
      quickArr[high] = temp;
      await _updateArrayWithDelay(quickArr);
      return (i + 1);
    }

    //function to sort the list using MERGE SORT and repaint the canvas at every iteration.
    _mergeSortVisualiser(List<int> mergeArr, int low, int high) async {
      if (low < high) {
        // Same as (l+r)/2, but avoids overflow for
        // large l and h
        int mid = (low + (high - low) / 2).toInt();
        // Sort first and second halves
        await _mergeSortVisualiser(mergeArr, low, mid);
        await _mergeSortVisualiser(mergeArr, mid + 1, high);
        _updateArrayWithDelay(mergeArr);
        await merge(mergeArr, low, mid, high);
      }
    }

//function to sort the list using QUICK SORT and repaint the canvas at every iteration.
    _quickSortVisualiser(List<int> quickArr, int low, int high) async {
      int pivot;
      if (low < high) {
        /* pi is partitioning index, arr[pi] is now
           at right place */
        pivot = await _partition(arr, low, high);

        await _quickSortVisualiser(quickArr, low, pivot - 1); // Before pi
        await _quickSortVisualiser(quickArr, pivot + 1, high); // After pi
      }
    }

    //helper function to partition array for quicksort

    heapify(List<int> heapArr, int n, int i) async {
      int largest = i;
      int l = 2 * i + 1;
      int r = 2 * i + 2;

      // If left child is larger than root
      if (l < n && heapArr[l] > heapArr[largest]) largest = l;

      // If right child is larger than largest so far
      if (r < n && heapArr[r] > heapArr[largest]) largest = r;
      // If largest is not root
      if (largest != i) {
        int swap = heapArr[i];
        heapArr[i] = heapArr[largest];
        heapArr[largest] = swap;
        await _updateArrayWithDelay(heapArr);
        // Recursively heapify the affected sub-tree
        await heapify(heapArr, n, largest);
      }
    }

//function to sort the list using HEAP SORT and repaint the canvas at every iteration.
    _heapSortVisualiser(List<int> heapArr) async {
      int n = heapArr.length;

      // Build heap (rearrange array)
      for (int i = n ~/ 2 - 1; i >= 0; i--) await heapify(heapArr, n, i);

      // One by one extract an element from heap
      for (int i = n - 1; i >= 0; i--) {
        // Move current root to end
        int temp = heapArr[0];
        heapArr[0] = heapArr[i];
        heapArr[i] = temp;
        await _updateArrayWithDelay(heapArr);
        // call max heapify on the reduced heap
        await heapify(heapArr, i, 0);
      }
    }

    //function to sort the list using SELECTION SORT and repaint the canvas at every iteration.
    _selectionSortVisualiser(arr) async {
      print('Selection sort visualiser called');
      List<int> selectArr = List.from(arr);
      int minIndex, temp;

      for (int i = 0; i < selectArr.length - 1; i++) {
        minIndex = i;
        for (int j = i + 1; j < selectArr.length; j++) {
          if (selectArr[j] < selectArr[minIndex]) {
            minIndex = j;
          }
        }

        temp = selectArr[i];
        selectArr[i] = selectArr[minIndex];
        selectArr[minIndex] = temp;

        await _updateArrayWithDelay(selectArr);
      }
    }

    //function to sort the list using INSERTION SORT and repaint the canvas at every iteration.
    _insertionSortVisualiser(arr) async {
      print('Insertion sort visualiser called');
      List<int> insertArr = List.from(arr);
      int key, j;

      for (int i = 1; i < insertArr.length; i++) {
        key = insertArr[i];
        j = i - 1;

        while (j >= 0 && insertArr[j] > key) {
          insertArr[j + 1] = insertArr[j];
          j = j - 1;
        }
        insertArr[j + 1] = key;
        await _updateArrayWithDelay(insertArr);
      }
    }

    ////function to sort the list using GNOME SORT and repaint the canvas at every iteration.
    _gnomeSortVisualiser(arr) async {
      List<int> gnomeArr = List.from(arr);
      int index = 0;

      while (index < gnomeArr.length) {
        if (index == 0) index++;
        if (gnomeArr[index] >= gnomeArr[index - 1])
          index++;
        else {
          int temp;
          temp = gnomeArr[index];
          gnomeArr[index] = gnomeArr[index - 1];
          gnomeArr[index - 1] = temp;
          await _updateArrayWithDelay(gnomeArr);
          index--;
        }
      }
    }

    final _stopWatchTimer = StopWatchTimer(
      onChange: (value) {
        final displayTime = StopWatchTimer.getDisplayTime(value);
        timeC = displayTime;
      },
    );

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: buildAppBar(context),
        body: Container(
          child: TabBarView(
            children: [
              new VisualSorting(scaffoldKey: _scaffoldKey),
              new CodeVS(scaffoldKey: _scaffoldKey),
              new ArrayVS(scaffoldKey: _scaffoldKey),
            ],
          ),
        ), // Body()
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.merge_type_outlined),
              label: 'Merge',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fast_forward),
              label: 'Quick',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward),
              label: 'Heap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart),
              label: 'Bubble',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upgrade),
              label: 'Insertion',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle),
              label: 'Selection',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_work),
              label: 'Gnome',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kOrangeColor,
          unselectedItemColor: kBlackColor,
          onTap: isAlgorithmRunning == true ? null : onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor:
                isAlgorithmRunning == true ? kRedColor : kTextLightColor,
            hoverColor: kOrangeColor,
            splashColor: kRedColor,
            label: isAlgorithmRunning == true
                ? Text("Sorting: " + timeC)
                : Text("Sort: " + timeC),
            icon: Icon(
              isAlgorithmRunning == true
                  ? Icons.stop
                  : Icons.play_arrow_rounded,
            ),
            onPressed: isAlgorithmRunning == true
                ? null
                : () async {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                    _setAlgorithmRunningState(true);
                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                    if (_selectedIndex == 0) {
                      await _mergeSortVisualiser(arr, 0, arr.length - 1);
                    } else if (_selectedIndex == 1) {
                      await _quickSortVisualiser(arr, 0, arr.length - 1);
                    } else if (_selectedIndex == 2) {
                      await _heapSortVisualiser(arr);
                    } else if (_selectedIndex == 3) {
                      await _bubbleSortVisualiser(arr);
                    } else if (_selectedIndex == 4) {
                      await _selectionSortVisualiser(arr);
                    } else if (_selectedIndex == 5) {
                      await _insertionSortVisualiser(arr);
                    } else if (_selectedIndex == 6) {
                      await _gnomeSortVisualiser(arr);
                    }
                    _setAlgorithmRunningState(false);
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                  }),
      ),
    );
  }
}

class CodeVS extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CodeVS({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _CodeVSState createState() => _CodeVSState();
}

class _CodeVSState extends State<CodeVS> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: Text(_selectedIndex == 0
                ? mergeAlgo
                : _selectedIndex == 1
                    ? quickAlgo
                    : _selectedIndex == 2
                        ? heapAlgo
                        : _selectedIndex == 3
                            ? bubbleAlgo
                            : _selectedIndex == 4
                                ? selectionAlgo
                                : _selectedIndex == 5
                                    ? insertionAlgo
                                    : _selectedIndex == 6
                                        ? gnomeAlgo
                                        : null),
          ),
        ],
      ),
    );
  }
}

class ArrayVS extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ArrayVS({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _ArrayVSState createState() => _ArrayVSState();
}

class _ArrayVSState extends State<ArrayVS> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              children: displayArr.map(
                (e) {
                  return SizedBox(
                    width: double.infinity,
                    height: 40.0,

                    // height: double.infinity,
                    child: Card(
                      semanticContainer: true,
                      margin: EdgeInsets.all(3),
                      elevation: 5,
                      color: isAlgorithmRunning == true
                          ? kRedLightColor
                          : kOrangeColor,
                      child: Center(
                        child: Text(
                          e.toString(),
                          style: TextStyle(
                            color: kTextLightColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class VisualSorting extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const VisualSorting({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _VisualSortingState createState() => _VisualSortingState();
}

class _VisualSortingState extends State<VisualSorting> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomPaint(
        willChange: true,
        isComplex: true,
        size: Size(window.physicalSize.width, double.negativeInfinity),
        painter: SortingCanvas(arr),
      ),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  widthUni = MediaQuery.of(context).size.width / 2;
  hieghtUni = MediaQuery.of(context).size.height / 2;
  return AppBar(
    backgroundColor: kOrangeColor,
    elevation: 0,
    title: Text(
      "Visual Sorter",
      style: TextStyle(fontWeight: FontWeight.bold, color: kTextLightColor),
    ),
    bottom: TabBar(
      labelColor: kTextLightColor,
      tabs: <Widget>[
        Tab(
            icon: Icon(
              Icons.leaderboard,
            ),
            text: "Visual"),
        Tab(
            icon: Icon(
              Icons.developer_mode,
            ),
            text: "Code"),
        Tab(
            icon: Icon(
              Icons.money,
            ),
            text: "Array"),
      ],
    ),
    actions: <Widget>[
      AbsorbPointer(
        absorbing: isAlgorithmRunning,
        child: Container(
          width: 200,
          child: MyStatefulSlider(),
        ),
      ),
      IconButton(
        icon: Icon(Icons.privacy_tip_rounded),
        color: kWhiteColor,
        tooltip: "Privacy Policy",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacyPolicy()),
          );
        },
      ),
    ],
  );
}

class MyStatefulSlider extends StatefulWidget {
  MyStatefulSlider({key}) : super(key: key);
  @override
  _MyStatefulSliderState createState() => _MyStatefulSliderState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulSliderState extends State<MyStatefulSlider> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      icon: Icon(Icons.settings_backup_restore_sharp, color: kTextLightColor),
      label: Text("Random", style: TextStyle(color: kTextLightColor)),
      color: kOrangeColor,
      onPressed: isAlgorithmRunning == true
          ? null
          : () {
              _reset();
              arr = _getRandomIntegerList(initArraySize);
            },
    );
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => HomeScreen(),
      ),
    );
  }
}

//Helper function to get a list of 10 random integers
List<int> _getRandomIntegerList(size) {
  List<int> arr = [];
  Random rng = new Random();

  size = widthUni.toInt() / 7;
  for (int i = 0; i < size; i++) {
    arr.add(rng.nextInt(ranLength) + 2);
  }
  return arr;
}

class SortingCanvas extends CustomPainter {
  List<int> arr;
  SortingCanvas(this.arr);

  @override
  void paint(Canvas canvas, Size size) async {
    //IMP the first offset is the bottom point and the second is the top point of the vertical line.
    //It is offset from the top left corner of the canvas

    for (int i = 1; i <= arr.length; i++) {
      var linePaint = Paint()
        ..color = _randomColor.randomColor(colorHue: ColorHue.orange)
        ..strokeWidth = initSrokeWidth
        ..isAntiAlias = true;
      canvas.drawLine(
          Offset(offsetBig + (offsetSmall * i), size.height - 20),
          Offset(offsetBig + (offsetSmall * i), offsetBig * arr[i - 1]),
          linePaint);
    }
  }

  @override
  bool shouldRepaint(SortingCanvas oldDelegate) =>
      !listEquals(this.arr, oldDelegate.arr);
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

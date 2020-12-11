import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visual_sorter/constants.dart';

var size = initArraySize;
const time = 200;
List<int> arr = _getRandomIntegerList(size);
Color color = kOrangeColor;
bool isAlgorithmRunning = false;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      arr = _getRandomIntegerList(size);
      isAlgorithmRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
//async update method to keep the body of recursive algorithms cleaner.
    _updateArrayWithDelay(List<int> updatedArr) async {
      color = kGreenColor;
      await Future.delayed(const Duration(milliseconds: time), () {
        setState(() {
          arr = List.from(updatedArr);
          color = kRedColor;
          color = kVioletColor;
        });
      });
    }

    void _bubbleSortVisualiser() async {
      List<int> bubbleArr = List.from(arr);
      for (int i = 0; i < bubbleArr.length - 1; i++) {
        for (int j = 0; j < bubbleArr.length - 1 - i; j++) {
          int temp;
          if (bubbleArr[j] < bubbleArr[j + 1]) {
            temp = bubbleArr[j];
            bubbleArr[j] = bubbleArr[j + 1];
            bubbleArr[j + 1] = temp;
            //Every time arr changes setState() is called to visualise the changing array.
            color = kGreenColor;
            await Future.delayed(const Duration(milliseconds: time), () {
              setState(() {
                arr = List.from(bubbleArr);
                color = kRedColor;
                color = kVioletColor;
              });
            });
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

    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.merge_type_outlined),
            label: 'Merge Sort',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fast_forward),
            label: 'Quick Sort',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Heap Sort',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bubble_chart),
            label: 'Bubble Sort',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kOrangeColor,
        unselectedItemColor: kBlackColor,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          backgroundColor: kTextLightColor,
          hoverColor: kOrangeColor,
          splashColor: kRedColor,
          // label: Text('Start'),
          //icon:
          child: Icon(
            Icons.play_arrow_rounded,
          ),
          onPressed: () {
            isAlgorithmRunning = true;
            if (_selectedIndex == 0) {
              _mergeSortVisualiser(arr, 0, arr.length - 1);
            } else if (_selectedIndex == 1) {
              _quickSortVisualiser(arr, 0, arr.length - 1);
            } else if (_selectedIndex == 2) {
              _heapSortVisualiser(arr);
            } else if (_selectedIndex == 3) {
              _bubbleSortVisualiser();
            }
            isAlgorithmRunning = false;
          }),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: kOrangeColor,
    elevation: 0,
    title: Text(
      "Visual Sorter",
      style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: kTextLightColor),
    ),
    actions: <Widget>[
      Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            "Change Array Size",
            style: TextStyle(fontSize: 15, color: kTextLightColor),
          )),
      Container(
        width: 150,
        child: MyStatefulSlider(),
      ),
      IconButton(
        icon: Icon(Icons.verified_user),
        color: kWhiteColor,
        tooltip: "Developed by Tamzid. Insipred by clementmihailescu.",
        onPressed: () {},
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
  double _currentSliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Slider(
        value: _currentSliderValue,
        min: 10,
        max: maxArraySize,
        divisions: 10,
        activeColor: kWhiteColor,
        inactiveColor: kAshColor,
        onChanged: (double value) {
          setState(
            () {
              if (isAlgorithmRunning == false) {
                _currentSliderValue = value;
                arr = _getRandomIntegerList(_currentSliderValue);
              }
            },
          );
        },
        onChangeStart: (double value) {
          if (isAlgorithmRunning == false) {
            _currentSliderValue = value;
          }
        },
        onChangeEnd: (double value) {
          if (isAlgorithmRunning == false) {
            _currentSliderValue = value;
            _reset(value);
          }
        });
  }

  void _reset(double value) async {
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
  for (int i = 0; i < size; i++) {
    arr.add(rng.nextInt(11) + 2);
  }
  return arr;
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          child: CustomPaint(
            willChange: true,
            isComplex: true,
            size: Size(window.physicalSize.width, double.negativeInfinity),
            painter: SortingCanvas(arr),
          ),
        ),
      ),
    );
  }
}

class SortingCanvas extends CustomPainter {
  List<int> arr;
  SortingCanvas(this.arr);

  @override
  void paint(Canvas canvas, Size size) async {
    var linePaint = Paint()
      ..color = color
      ..strokeWidth = initSrokeWidth
      ..isAntiAlias = true;

    //IMP the first offset is the bottom point and the second is the top point of the vertical line.
    //It is offset from the top left corner of the canvas

    for (int i = 1; i <= arr.length; i++) {
      canvas.drawLine(
          Offset(offsetBig + (offsetSmall * i), size.height - 20),
          Offset(offsetBig + (offsetSmall * i), offsetBig * arr[i - 1]),
          linePaint);
    }
  }

  @override
  bool shouldRepaint(SortingCanvas oldDelegate) => true;
  // !listEquals(this.arr, oldDelegate.arr);
}

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

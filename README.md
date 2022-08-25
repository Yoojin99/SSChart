# SSChart

Simple Swift Chart library for iOS

🎯 Minimized features, focused on just showing graph.

## Chart Types

|Chart||
|-|-|
|Doughnut|![DoughnutGif](https://user-images.githubusercontent.com/41438361/186335760-452818e9-3552-4383-b139-072845829b72.gif)|
|Gauge|![GaugeGif](https://user-images.githubusercontent.com/41438361/186335991-ef23ae60-62b7-47ff-b67a-f8fc9b60977b.gif)|
|Horizontal Bar|![Bar1Gif](https://user-images.githubusercontent.com/41438361/186336222-f3872d36-f2c3-45f1-abec-7d3c56ed781b.gif)|
||![Bar2Gif](https://user-images.githubusercontent.com/41438361/186336227-55018c2d-2a16-4f66-9831-820bd27cde02.gif)|

## Features

1. Animation
2. Pause and Resume Animation : *Use this for starting animation when chart becomes visible.*
3. Customizable chart view(e.g. color)

![Simulator Screen Recording - iPhone 12 Pro - 2022-08-24 at 08 28 02](https://user-images.githubusercontent.com/41438361/186333466-42f0ba52-d667-4252-995d-5e30c2563870.gif)

3. Draw average line in bar chart

![Simulator Screen Recording - iPhone 12 Pro - 2022-08-24 at 12 24 10](https://user-images.githubusercontent.com/41438361/186333630-af065cef-bc9e-4e8f-b39a-929e87f629c1.gif)

## How To Use

1. Create chart

```swift
let doughnutChart = DoughnutChart(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
```

2. Create chart items

```swift
let chartItems: [DoughnutChartItem] = [
    DoughnutChartItem(value: 15, color: .systemRed),
    DoughnutChartItem(value: 25, color: .systemOrange),
    DoughnutChartItem(value: 18, color: .systemYellow),
    DoughnutChartItem(value: 20, color: .systemGreen),
    DoughnutChartItem(value: 12, color: .systemBlue),
    DoughnutChartItem(value: 11, color: .systemPurple),
]
```

3. Set chart items to chart

```swift
doughnutChart.items = chartItems
```

4. Done!

![TestDoughnut](https://user-images.githubusercontent.com/41438361/186339539-056a4edb-955a-485c-b1d1-980fdfe632cc.gif)

## Customizable Options

### Doughnut

#### DoughnutChart

|Options|Description|
|-|-|
|`outerCircleRadiusRatio`|Ratio of width to outer circle radius. Default 2|
|`innerCircleRadiusRatio`|Ratio of width to innder circle radius. Default 6|
|`animationDuration`|Default 1.0|

e.g. `outerCircleRadiusRatio` = 2, `innerCircleRadiusRatio` = 6

<img width="385" alt="image" src="https://user-images.githubusercontent.com/41438361/186347439-5813bbfb-026e-4564-8b2c-98e5da4dbdf1.png">

#### DoughnutChartItem

|Options|Description|
|-|-|
|`color`|color of each item|

### Gauge

#### GaugeChart

|Options|Description|
|-|-|
|`outerCircleRadiusRatio`|Ratio of width to outer circle radius. Default 2|
|`innerCircleRadiusRatio`|Ratio of width to innder circle radius. Default 6|
|`animationDuration`|Default 1.0|
|`gaugeWidth`|width of gauge line. Default 15|

<img width="256" alt="image" src="https://user-images.githubusercontent.com/41438361/186348286-9dcf40a7-9b52-4a0e-b7f4-4fb0780ab536.png">

#### GaugeChartItem

|Options|Description|
|-|-|
|`color`|color of each item|

### Bar

|Options|Description|
|-|-|
|`groupSpace`|space between groups. Default 10|
|`itemSpace`|space between items. Default 3|
|`groupLabelWidth`|width of group text label. Default 52|
|`itemLabelWidth`|width of item text label. Default 52|
|`descriptionLabelWidth`|width of description text label. Default 52|
|`animationDelayInterval`|time interval between animation start time for each bar. Default 0.3|
|`showAverageLine`|Default false|
|`averageLineColor`|color of average line. Default systemRed|


### BarItem

|Options|Description|
|-|-|
|`color`|color of bar|
|`font`|font of label|
|`textColor`|text color of label|

## Notes

### Bar Chart

#### Bar Chart Items Hierarchy

* BarChartGroupItem
* BarChartItem

1. GroupItem can have many Items.
2. GroupItem and Item can have label.
3. Item can have descriptionLabel.

<img width="868" alt="image" src="https://user-images.githubusercontent.com/41438361/186341748-bc661631-0f10-41ee-86a0-600d6fa16f80.png">

#### How Bar Chart Draws Items

Bar chart draws items as below.

|Group Label(if exists)|Item Label(if exists)|Bar|Item Description Label(if exists)|
|-|-|-|-|

<img width="652" alt="image" src="https://user-images.githubusercontent.com/41438361/186341797-b7ca4668-9358-4d18-8e1e-87c265f22366.png">

* If there is a group that has label, bar draws group label section.
* If there is an item that has label, bar draws item label section.
* If there is an item that has description label, bar draws item description label section.

#### Various Bar Chart Item Configuration

1. Group : Item = 1 : N

```swift
[
    BarChartGroupItem(
        items: [
            BarChartItem(value: 3, label: BarChartLabelItem(text: "삼색이", textColor: UIColor.systemGray), color: .init(red: 233/255, green: 29/255, blue: 41/255, alpha: 1)),
            BarChartItem(value: 5, label: BarChartLabelItem(text: "도도", textColor: UIColor.systemGray), color: .init(red: 203/255, green: 32/255, blue: 39/255, alpha: 1)),
            BarChartItem(value: 4, label: BarChartLabelItem(text: "마를린", textColor: UIColor.systemGray), color: .init(red: 179/255, green: 32/255, blue: 36/255, alpha: 1))
        ],
        label: BarChartLabelItem(text: "삼색이네")
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 5, label: BarChartLabelItem(text: "무", textColor: UIColor.systemGray), color: .init(red: 253/255, green: 243/255, blue: 170/255, alpha: 1)),
            BarChartItem(value: 9, label: BarChartLabelItem(text: "연님", textColor: UIColor.systemGray), color: .init(red: 251/255, green: 236/255, blue: 123/255, alpha: 1)),
            BarChartItem(value: 5, label: BarChartLabelItem(text: "래기", textColor: UIColor.systemGray), color: .init(red: 249/255, green: 229/255, blue: 76/255, alpha: 1))
        ],
        label: BarChartLabelItem(text: "연님이네")
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 10, label: BarChartLabelItem(text: "뚱땅"), color: .init(red: 0/255, green: 166/255, blue: 81/255, alpha: 1)),
        ],
        label: BarChartLabelItem(text: "뚱땅이네")
    ),
]
```

![image](https://user-images.githubusercontent.com/41438361/186349765-4df949cc-4c1f-4985-a237-5c980994b553.png)

2. Group : Item = 1 : 1

```swift
[
    BarChartGroupItem(
        items: [
            BarChartItem(value: 3, label: BarChartLabelItem(text: "삼색이"), color: .systemRed, descriptionLabel: BarChartLabelItem(text: "3마리"))
        ]
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 4, label: BarChartLabelItem(text: "야통이"), color: .systemOrange, descriptionLabel: BarChartLabelItem(text: "4마리"))
        ]
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 5, label: BarChartLabelItem(text: "무"), color: .systemYellow, descriptionLabel: BarChartLabelItem(text: "5마리"))
        ]
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 5, label: BarChartLabelItem(text: "래기"), color: .systemGreen, descriptionLabel: BarChartLabelItem(text: "5마리"))
        ]
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 9, label: BarChartLabelItem(text: "연님"), color: .systemBlue, descriptionLabel: BarChartLabelItem(text: "9마리"))
        ]
    ),
    BarChartGroupItem(
        items: [
            BarChartItem(value: 4, label: BarChartLabelItem(text: "마를린"), color: .systemPurple, descriptionLabel: BarChartLabelItem(text: "4마리"))
        ]
    )
]
```

![image](https://user-images.githubusercontent.com/41438361/186349705-3a1ffcfa-cef5-4ef9-8d94-36d5d8b2a534.png)


### Detect chart is visible

If a chart exists as content of scroll view or stack view, chart might be not visible at first. So it is necessary to pause animation at first time and resume animation when chart becomes visible. To do this, follow the steps:

1. Call `pauseAnimation()` method. **You should call `pauseAnimation()` method after setting chart data to chart. Calling `pauseAnimation()` before setting data won't work.**

```swift
private func pauseChartAnimation() {
    barChart.pauseAnimation()
    doughnutChart.pauseAnimation()
    gaugeChart.pauseAnimation()
}
```

2. Call `resumeAnimation()` when necessary. (e.g. if chart is in the scrollview, you can determine whether chart is visible by calling `intersects()` method)

```swift
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.bounds.intersects(barChart.frame) {
        barChart.resumeAnimation()
    }

    if scrollView.bounds.intersects(doughnutChart.frame) {
        doughnutChart.resumeAnimation()
    }

    if scrollView.bounds.intersects(gaugeChart.frame) {
        gaugeChart.resumeAnimation()
    }
}
```

#### Result

![Simulator Screen Recording - iPhone 12 Pro - 2022-08-24 at 08 28 02](https://user-images.githubusercontent.com/41438361/186343925-6d08ebda-1ce7-4140-abe4-7491d9b14795.gif)

Animation starts when chart is visible.

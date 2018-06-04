//
//  AssetDetailViewController.swift
//  AssetAR
//
//  Created by Jules on 23/01/2018.
//  Copyright © 2018 Gribble. All rights reserved.
//

import UIKit
import Charts

class AssetDetailViewController:UIViewController,UINavigationControllerDelegate,ChartViewDelegate
{
    
    @IBOutlet var assetName: UILabel!
    @IBOutlet var lattitude: UILabel!
    @IBOutlet var longitude: UILabel!
    @IBOutlet var organisation: UILabel!
    @IBOutlet var lineChart: LineChartView!
    
    
    var orgText:String?
    var fromAR:Bool = false
    var asset:Asset? = nil
    var dataPoints:[DataPoint] = []
    
    @IBAction func back(_ sender: Any) {
        //
        if(fromAR){
            self.performSegue(withIdentifier: "goBackToAR", sender: self)
        } else{
            self.performSegue(withIdentifier: "goBackToList", sender: self)
        }
        
        
    }
    
    @IBAction func deleteAsset(_ sender: Any) {
        let alert = UIAlertController(title: "Delete '\(self.asset?.assetName ?? "")'",
                                      message: "Are you sure you want to delete the asset '\(self.asset?.assetName ?? "")'",
                                      preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) -> Void in
            if(self.deleteAssets(assetID: (self.asset?.id)!)){
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as? HomeViewController {
                    self.present(viewController, animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Can not delete assets please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        self.present(alert,animated: true,completion: nil)
        
       
        
    }
    
    func deleteAssets(assetID:Int)->Bool{
        var status = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async{
            SessionManager.shared.credentialsManager.credentials { error, credentials in
                guard error == nil, let credentials = credentials else {
                    // Handle Error
                    // Route user back to Login Screen
                    return
                }
                print("Access Token \(credentials.accessToken ?? "NO access token tstored")")
                let url = URL(string: "https://assetar-stg.herokuapp.com/api/delete/"+String(assetID))
                var request = URLRequest(url: url!)
                request.httpMethod = "DELETE"
                // Configure your request here (method, body, etc)
                request.addValue("Bearer \(credentials.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                print("Bearer \(credentials.accessToken ?? "")")
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    guard let data = data else {
                        status = false
                        group.leave()
                        return
                    }
                    print(response!)
                    // when the repsonse is returned output response
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject] else {
                        print("Can not convert data to JSON object")
                        status = false
                        group.leave()
                        return
                    }
                    print("----------------------------------")
                    print(json!)
                    print("----------------------------------")
                   
                    status = true
                    group.leave()
                })
                task.resume()
                
            }
        }
        group.wait()
        return status
    }
    
    func makeChart(){
        var chartValues:[ChartDataEntry] = []
        for dataPoint in self.dataPoints{
            chartValues.append(ChartDataEntry(x: dataPoint.timestamp.timeIntervalSince1970 * 1000.0, y: Double(dataPoint.data)!))
        }
        let set1 = LineChartDataSet(values: chartValues, label: "\(asset?.assetName ?? "")")
        set1.drawIconsEnabled = false
        
//        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        lineChart.data = data
        lineChart.reloadInputViews()
        lineChart.animate(xAxisDuration: 2.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.delegate = self
        self.lineChart.delegate = self
        if(asset != nil){
            assetName?.text = asset?.assetName
            lattitude?.text = asset?.assetLocationX.description
            longitude?.text = asset?.assetLocationZ.description
            organisation?.text = orgText!
            self.dataPoints = APIAccess.access.getAssetData(id: (asset?.id)!)
            lineChart.xAxis.valueFormatter = DateValueFormatter()
         //   lineChart.zoomToCenter(scaleX: 10, scaleY: 10)
            if(self.dataPoints.count>0){
                self.makeChart()
            }
           
        }
      
    }
}

private class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


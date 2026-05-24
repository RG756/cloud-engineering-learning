Sub CalculateAverageSalaryFullColor()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("Sheet1")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    Dim sumMale As Long, countMale As Long
    Dim sumFemale As Long, countFemale As Long
    Dim i As Long
    
    For i = 2 To lastRow
        If ws.Cells(i, "C").Value = "男" Then
            sumMale = sumMale + ws.Cells(i, "E").Value
            countMale = countMale + 1
        ElseIf ws.Cells(i, "C").Value = "女" Then
            sumFemale = sumFemale + ws.Cells(i, "E").Value
            countFemale = countFemale + 1
        End If
    Next i
    
    ' --- ① 見出し（1行目）の色付け ---
    With ws.Range("G1:H1")
        .Value = Array("性別", "平均給与")
        .Interior.Color = RGB(146, 208, 80)   ' 濃い黄緑
        .Font.Color = RGB(255, 255, 255)      ' 白文字
        .Font.Bold = True
    End With
    
    ' --- ② データ行（2?3行目）の色付け ---
    ' 男性の行（薄い緑）
    With ws.Range("G2:H2")
        .Interior.Color = RGB(226, 239, 218)
        .Cells(1, 1).Value = "男"
        If countMale > 0 Then .Cells(1, 2).Value = sumMale / countMale
    End With
    
    ' 女性の行（もう少し薄い緑、または同じ色）
    With ws.Range("G3:H3")
        .Interior.Color = RGB(242, 248, 238)
        .Cells(1, 1).Value = "女"
        If countFemale > 0 Then .Cells(1, 2).Value = sumFemale / countFemale
    End With
    
    ' --- ③ 書式と枠線の仕上げ ---
    ws.Range("H2:H3").NumberFormatLocal = "#,##0"
    ws.Range("G1:H3").Borders.LineStyle = xlContinuous
    ws.Columns("G:H").AutoFit

    'MsgBox "カラー版の表が完成しました！"
End Sub

Sub CalculateDepartmentAverage()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("Sheet1")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' 各部署の「合計給与」と「人数」を入れる箱を用意
    Dim sumSales As Long, countSales As Long      ' 営業
    Dim sumHR As Long, countHR As Long            ' 人事
    Dim sumDev As Long, countDev As Long          ' 開発
    Dim sumGA As Long, countGA As Long            ' 総務（追加！）
    Dim sumAcc As Long, countAcc As Long          ' 経理（追加！）
    Dim i As Long
    
    ' ループ処理で部署ごとに集計（D列が部署）
    For i = 2 To lastRow
        Select Case ws.Cells(i, "D").Value
            Case "営業"
                sumSales = sumSales + ws.Cells(i, "E").Value
                countSales = countSales + 1
            Case "人事"
                sumHR = sumHR + ws.Cells(i, "E").Value
                countHR = countHR + 1
            Case "開発"
                sumDev = sumDev + ws.Cells(i, "E").Value
                countDev = countDev + 1
            Case "総務"
                sumGA = sumGA + ws.Cells(i, "E").Value
                countGA = countGA + 1
            Case "経理"
                sumAcc = sumAcc + ws.Cells(i, "E").Value
                countAcc = countAcc + 1
        End Select
    Next i
    
    ' --- ① 見出し（J1・K1）の作成と色付け ---
    With ws.Range("J1:K1")
        .Value = Array("部署名", "平均給与")
        .Interior.Color = RGB(0, 112, 192)    ' 濃い青色
        .Font.Color = RGB(255, 255, 255)      ' 白文字
        .Font.Bold = True
    End With
    
    ' --- ② 各部署の結果入力と背景色 ---
    ' 営業 (J2:K2)
    ws.Range("J2").Value = "営業"
    If countSales > 0 Then ws.Range("K2").Value = sumSales / countSales
    ws.Range("J2:K2").Interior.Color = RGB(221, 235, 247) ' 薄い青
    
    ' 人事 (J3:K3)
    ws.Range("J3").Value = "人事"
    If countHR > 0 Then ws.Range("K3").Value = sumHR / countHR
    ws.Range("J3:K3").Interior.Color = RGB(242, 242, 242) ' 薄いグレー
    
    ' 開発 (J4:K4)
    ws.Range("J4").Value = "開発"
    If countDev > 0 Then ws.Range("K4").Value = sumDev / countDev
    ws.Range("J4:K4").Interior.Color = RGB(221, 235, 247) ' 薄い青
    
    ' 総務 (J5:K5)
    ws.Range("J5").Value = "総務"
    If countGA > 0 Then ws.Range("K5").Value = sumGA / countGA
    ws.Range("J5:K5").Interior.Color = RGB(242, 242, 242) ' 薄いグレー
    
    ' 経理 (J6:K6)
    ws.Range("J6").Value = "経理"
    If countAcc > 0 Then ws.Range("K6").Value = sumAcc / countAcc
    ws.Range("J6:K6").Interior.Color = RGB(221, 235, 247) ' 薄い青
    
    
    ' --- ③ 書式と枠線の仕上げ ---
    ws.Range("K2:K6").NumberFormatLocal = "#,##0"      ' カンマ区切り
    ws.Range("J1:K6").Borders.LineStyle = xlContinuous ' 枠線
    ws.Columns("J:K").AutoFit                          ' 幅調整

    'MsgBox "部署別の集計も完了しました！"
End Sub

Sub CalculateOverallAverage()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("Sheet1")
    
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' 全体の合計を入れる箱
    Dim totalAge As Double, totalSalary As Double
    Dim dataCount As Long
    Dim i As Long
    
    ' ループ処理で全員分を足していく
    For i = 2 To lastRow
        totalAge = totalAge + ws.Cells(i, "B").Value    ' B列：年齢
        totalSalary = totalSalary + ws.Cells(i, "E").Value  ' E列：給与
        dataCount = dataCount + 1
    Next i
    
    ' --- ① 見出し（M1・N1）の作成と色付け ---
    ' M列：平均年齢
    With ws.Range("M1")
        .Value = "平均年齢"
        .Interior.Color = RGB(255, 192, 0)     ' オレンジ色
        .Font.Bold = True
    End With
    
    ' N列：全体平均給与
    With ws.Range("N1")
        .Value = "全体平均給与"
        .Interior.Color = RGB(255, 192, 0)     ' オレンジ色
        .Font.Bold = True
    End With
    
    ' --- ② 結果の入力と色付け ---
    If dataCount > 0 Then
        ' 平均年齢（小数点第1位まで表示するように調整）
        ws.Range("M2").Value = totalAge / dataCount
        ws.Range("M2").NumberFormatLocal = "0.0歳"
        
        ' 全体平均給与
        ws.Range("N2").Value = totalSalary / dataCount
        ws.Range("N2").NumberFormatLocal = "#,##0円"
    End If
    
    ' 背景色（薄いオレンジ）と枠線
    With ws.Range("M2:N2")
        .Interior.Color = RGB(255, 242, 204)
        .Borders.LineStyle = xlDash
    End With
    
    ' 見出しの枠線と幅調整
    ws.Range("M1:N1").Borders.LineStyle = xlDash
    ws.Columns("M:N").AutoFit

    'MsgBox "全体集計も完了しました！"
End Sub

Sub RunAllCalculations()
    ' 1. 画面の更新を一時停止する（これが魔法の1行！）
    Application.ScreenUpdating = False
    
    ' これまで作ったマクロを順番に呼び出す
    Call ClearDashboard
    Call CalculateAverageSalaryFullColor
    Call CalculateDepartmentAverage
    Call CalculateOverallAverage
    
    ' 2. 全ての計算が終わったので、画面更新を再開する
    Application.ScreenUpdating = True
    
    MsgBox "すべての集計が完了しました！"
End Sub

Sub ClearDashboard()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets("Sheet1")
    
    ' 集計エリア（G列からN列）を特定して、中身と書式を全部消す！
    ' 1行目（見出し）から、余裕を持って100行目くらいまでを対象にします
    With ws.Range("G1:N100")
        .ClearContents     ' 値（文字や数字）を消す
        .Interior.Color = xlNone  ' 背景色を「なし」にする
        .Borders.LineStyle = xlNone ' 枠線を消す
    End With
    
    'MsgBox "集計エリアをリセットしました。"
End Sub

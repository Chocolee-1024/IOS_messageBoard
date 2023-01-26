import UIKit
import RealmSwift
class MessageBoardViewController: UIViewController {
    
    @IBOutlet weak var messagePeopleLabel: UILabel!
    @IBOutlet weak var messagePeopleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var messageArray: [Message] = []
    var optionsArray: [String] = ["預設","舊到新","新到舊"]
    let localDatabase = LocalDatabase.SharedInstance()
    enum SortRule{
        case oldToNew
        case newToOld
        case `default`
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    //畫面即將出現的生命週期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMessage()
    }
    //設定UI樣式
    private func setupUI(){
        setupTableView()
        setupLabel()
        setupButton()
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyBoard))
        view.addGestureRecognizer(tap)
    }
    //設定Label樣式
    private func setupLabel(){
        messagePeopleLabel.text = "留言人"
        messageLabel.text = "留言內容"
    }
    //設定TableView樣式
    private func setupTableView(){
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifire)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        
    }
    //設定Button樣式
    private func setupButton(){
        sendButton.setTitle("送出", for: .normal)
        sortButton.setTitle("排序", for: .normal)
        sendButton.backgroundColor = .init(red: 0, green: 255, blue: 255, alpha: 1)
        sortButton.backgroundColor = .init(red: 0, green: 255, blue: 255, alpha: 1)
        sendButton.setTitleColor(.black, for: .normal)
        sortButton.setTitleColor(.black, for: .normal)
        sendButton.layer.cornerRadius = 15
        sortButton.layer.cornerRadius = 15

    }
    //設定送出成功提示欄
    func showAlert(title: String?, message: String?, confirmTitle: String?, confirm: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAlert = UIAlertAction(title: confirmTitle, style: .default){ _ in
            confirm?()
        }
        alertController.addAction(confirmAlert)
        present(alertController, animated: true)
    }
    //設定選擇排序功能
    func showAlertSheet(title: String?, message: String?, options: [String], confirm: ((Int) -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for option in options{
            let index = options.firstIndex(of: option)
            let action = UIAlertAction(title: option, style: .default){ _ in
                confirm?(index!)
            }
            alertController.addAction(action)
        }
        let cancelAlert = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAlert)
        present(alertController, animated: true)
    }
    //排序
    func sortMessage(rule: SortRule) -> [Message]{
        return messageArray.sorted(by: {prev, next in
            switch rule{
            case .oldToNew:
                return prev.timestamp < next.timestamp
            case .newToOld:
                return prev.timestamp > next.timestamp
            case .default:
                return prev.timestamp > next.timestamp
            }
        })
    }
    //關閉鍵盤
    @objc func closeKeyBoard(){
        view.endEditing(true)
    }

    //撈資料
    func fetchMessage(){
        DispatchQueue.global().async {
            self.messageArray = self.localDatabase.fetchFromDatabase()
        }
        DispatchQueue.main.async {
            self.messageTableView.reloadData()
        }
    }
 

    //檢查是否有填值
    func UpdataMessageCheck(message: Message){
        guard let messagePeople = messagePeopleTextField.text, !(messagePeople.isEmpty)else{
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉"){
                self.messageTextView.text = ""
            }
            return
        }
        guard let messageContext = messageTextView.text, !(messageContext.isEmpty)else{
            showAlert(title: "錯誤", message: "請輸入留言內容", confirmTitle: "關閉"){
                self.messagePeopleTextField.text = ""
            }
            return
        }
        localDatabase.UpdataMessage(message: message, messagePeople: messagePeople, messageContext: messageContext)
        
        showAlert(title: "成功", message: "更新留言成功!!", confirmTitle: "關閉"){
            self.messagePeopleTextField.text = ""
            self.messageTextView.text = ""
        }
        
        
    }
    //送出按鈕事件
    @IBAction func sendButtonClick(_ sender: UIButton){
        closeKeyBoard()
        guard let messagePeople = messagePeopleTextField.text, !(messagePeople.isEmpty)else{
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉"){
                self.messageTextView.text = ""
            }
            return
        }
        guard let messageContext = messageTextView.text, !(messageContext.isEmpty)else{
            showAlert(title: "錯誤", message: "請輸入留言內容", confirmTitle: "關閉"){
                self.messagePeopleTextField.text = ""
            }
            return
        }
        showAlert(title: "成功", message: "留言已送出!!", confirmTitle: "關閉"){
            self.messagePeopleTextField.text = ""
            self.messageTextView.text = ""
        }
        let message = Message(name: messagePeople,
                          context: messageContext,
                          timestamp: Int64(Date().timeIntervalSince1970))
        localDatabase.addMessage(message: message)
        fetchMessage()
    }
    //排序按鈕事件
    @IBAction func sortButtonClick(_ sender: UIButton){
        showAlertSheet(title: "請選擇排序方法",message: "chocolee", options: optionsArray){ index in
            self.localDatabase.SortMessage(index: index)
            self.fetchMessage()
        }
    }
}
//實作TableView
extension MessageBoardViewController: UITableViewDataSource, UITableViewDelegate{
    //有幾個Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    //Row顯示內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifire, for: indexPath) as? MessageTableViewCell else{
            fatalError("MessageTableViewCell Load Failed")
        }
        cell.MessagepeopleLabel.text = "留言人：\(messageArray[indexPath.row].name)"
        cell.MessageLabel.text = "留言內容：\(messageArray[indexPath.row].context)"
        return cell
    }
    //Cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    //左滑刪除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { action, sourceView, completionHandler in
            let deleteMessage =  self.messageArray[indexPath.row]
            self.localDatabase.deleteMessage(message: deleteMessage)
            self.fetchMessage()
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    //右滑更新
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updataAction = UIContextualAction(style: .destructive, title: "更新") { action, sourceView, completionHandler in
            let updataMessage =  self.messageArray[indexPath.row]
            self.UpdataMessageCheck(message: updataMessage)
            self.fetchMessage()
            completionHandler(true)
        }
        updataAction.image = UIImage(systemName: "pencil")
        updataAction.backgroundColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [updataAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}

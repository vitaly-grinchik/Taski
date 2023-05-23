//
//  TaskListViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // Доступ к зоне ОЗУ с объектами БД
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "taskCell"
    
    private var taskList = [Task]()
    
    lazy private var addButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: self,
        action: #selector(addButtonTapped)
    )
    
    private let appColor = UIColor(
        red: 21/255,
        green: 101/255,
        blue: 192/255,
        alpha: 194/255
    )
    
    lazy private var cancelAction = UIAlertAction(title: "Cancel",
                                             style: .default) { [unowned self] _ in
        dismiss(animated: true)
    }
    
    lazy private var saveAction = UIAlertAction(title: "Save",
                                                style: .default) { [unowned self] _ in
        
    }
    
    lazy private var deleteAction: UIContextualAction = {
        let delete = UIContextualAction(style: .destructive, title: "") {_, _, _ in
            print("Deleting ....")
        }
        delete.image = UIImage(systemName: "trash")
        return delete
    }()
    
    lazy private var editAction: UIContextualAction = {
        let edit = UIContextualAction(style: .normal, title: "") {_, _, _ in
            print("Editing ....")
        }
        edit.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        edit.image = UIImage(systemName: "pencil.line")
        return edit
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Регистрация ячеки таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNaviBar()
        fetchData()
    }
    
    // Настройка navigation bar
    private func setupNaviBar() {
        let naviBarAppearance = UINavigationBarAppearance()
        
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true // Крупный шрифт названия
        
        // Цвета
        navigationController?.navigationBar.tintColor = .white
        naviBarAppearance.backgroundColor = appColor
        naviBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // для рекомендованного Apple крупного размера текста
        naviBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] // для обычного размера текста
        
        // Стиль текста (аттрибуты)
        navigationController?.navigationBar.standardAppearance = naviBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = naviBarAppearance
        
        // Добавляем системные кнопки "Addz"
        navigationItem.rightBarButtonItem = addButton
    
    }
    
    // MARK: - Add, edit, delete task records
    @objc private func addButtonTapped() {
        showAlert(withTitle: "New task",
                  andMessage: "Add new task?",
                  usingTextField: true,
                  andActions: cancelAction, saveAction) { [weak self] task in
            self?.addTask(task)
        }
        
    }
    
    private func addTask(_ taskTitle: String){
        // Инициализация экземпляра модели в контексте
        let task = Task(context: viewContext)
        task.title = taskTitle
        
        taskList.append(task)
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        saveContext()
    }
    
    private func deleteTask(_ task: Task) {
        guard let index = taskList.firstIndex(of: task) else { return }
        taskList.remove(at: index)
    }
    
    private func editTask(_ task: Task) {
        
    }
    
    // MARK: - Fetch and save data
    private func fetchData() {
        // Указываем, какой тип данных нужно извлечь из БД -> тип Task
        let fetchRequest = Task.fetchRequest()
        // Пробуем извлечь данные
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        // Не выполнять первое действия при полном свайпе
        swipeConfig.performsFirstActionWithFullSwipe = false
        return swipeConfig
    }

}

extension TaskListViewController {
    
    private func showAlert(withTitle title: String,
                      andMessage message: String?,
                      usingTextField withTextField: Bool,
                      andActions actions: UIAlertAction...,
                           compleationHandler: (String) -> Void)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if withTextField {
            alert.addTextField()
            alert.textFields?.forEach { $0.clearsOnBeginEditing = true }
        }
        actions.forEach {alert.addAction($0) }
        
        if let text = alert.textFields?.first?.text {
            compleationHandler(text)
        }
        
        present(alert, animated: true)
    }
}

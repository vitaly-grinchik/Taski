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
    
    lazy private var cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
    { [unowned self] _ in dismiss(animated: true) }
    
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
    
    // MARK: - Add task
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "New task",
                                      message: "Add new task?",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { [unowned self] _ in
            guard let taskName = alert.textFields?.first?.text else { return }
            if !taskName.isEmpty {
                // Инициализация экземпляра модели в контексте
                let task = Task(context: viewContext)
                task.title = taskName
                taskList.append(task)
                let indexPath = IndexPath(row: taskList.count - 1, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
                
                StorageManager.shared.saveContext()
            }
        }
        alert.addTextField()
        alert.textFields?.first?.placeholder = "New task"
        alert.textFields?.first?.clearButtonMode = .whileEditing
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
        // Delete swipe action
        let deleteAction: UIContextualAction = {
            let delete = UIContextualAction(style: .destructive, title: "")
            { [unowned self] _, _, _ in
                let task = taskList.remove(at: indexPath.row)
                viewContext.delete(task)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                StorageManager.shared.saveContext()
            }
            delete.image = UIImage(systemName: "trash")
            return delete
        }()
        
        // Edit swipe action with alert
        let editAction: UIContextualAction = {
            let edit = UIContextualAction(style: .normal, title: "")
            { [unowned self] _, _, completionHandler in
                let alert = UIAlertController(title: "Edit task",
                                              message: nil,
                                              preferredStyle: .alert)
                
                let saveAction = UIAlertAction(title: "Save",
                                               style: .default) { [unowned self] _ in
                    
                    
                    guard let taskName = alert.textFields?.first?.text else { return }
                    
                    if !taskName.isEmpty {
                        taskList[indexPath.row].title = taskName
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    StorageManager.shared.saveContext()
                }
                
                alert.addTextField()
                alert.textFields?.forEach { $0.clearButtonMode = .whileEditing }
                // Вывод имеющеготся названия задачи в текстовон поле
                let taskName = taskList[indexPath.row].title
                alert.textFields?.first?.text = taskName
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
                // dismiss swipe
                completionHandler(true)
            }
            edit.image = UIImage(systemName: "pencil.line")
            return edit
        }()
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        // Не выполнять первое действия при полном свайпе
        swipeConfig.performsFirstActionWithFullSwipe = false
        return swipeConfig
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        taskList.isEmpty ? "No task found" : nil
    }
    
}

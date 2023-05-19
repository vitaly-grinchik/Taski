//
//  TaskListViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit

class TaskListViewController: UITableViewController {

    private let viewContext = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext
    
    private let cellID = "taskCell"
    
    private var taskList = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Регистрация ячеки таблицы
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNaviBar()
        fetchData()
    }
    
    private func setupNaviBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Настройка представления navigation bar
        let naviBarAppearance = UINavigationBarAppearance()
        naviBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        // Стиль текста (аттрибуты)...
        // ...для обычного размера текста ...
        naviBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        // ... и для рекомендованного Apple крупного размера текста
        naviBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = naviBarAppearance
        // The appearance settings for the Navigation bar when the edge of scrollable content aligns with the edge of the Navigation bar.
        navigationController?.navigationBar.scrollEdgeAppearance = naviBarAppearance
        // Добавляем системную кнопку в Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        // Определяем цвет элементов Navigation Bar
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addTask() {
        showAlert(withTitle: "New task",
                  andMessage: "Add task name"
        )
    }
    
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
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        // Инициализация контроллера
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Определение действий
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        // Привязка действий к контроллеру
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        // Добавление текстового поля
        alert.addTextField { textField in
            textField.placeholder = "New task"
        }
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        // Создаём экземпляр модели в контексте БД
        let task = Task(context: viewContext)
        // Передаем данные в атрибут объекта модели БД
        task.title = taskName
        taskList.append(task)
        // Определяем индекс последнего элемента
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        
        tableView.insertRows(at: [cellIndex], with: .automatic)
        // Сохранение если были изменения
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

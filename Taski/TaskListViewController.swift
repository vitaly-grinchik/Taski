//
//  TaskListViewController.swift
//  Taski
//
//  Created by Виталий Гринчик on 18.05.23.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

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
        let taskVC = TaskViewController()
        taskVC.delegate = self
//        taskVC.modalPresentationStyle = .fullScreen // МОДАЛЬНОЕ представление на весь экран
        present(taskVC, animated: true) // МОДАЛЬНОЕ представление  
//        navigationController?.pushViewController(taskVC, animated: true) // Представление SHOW
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

// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

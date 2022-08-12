//
//  TaskListController.swift
//  ToDoManager
//
//  Created by Nataliya Lazouskaya on 9.08.22.
//

import UIKit

class TaskListController: UITableViewController {
    
    var tasksStorage: TasksStorageProtocol = TasksStorage()
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet{
            for (taskGroupPriority, tasksGroup) in tasks {
                tasks[taskGroupPriority] = tasksGroup.sorted{ task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            var savingArray: [TaskProtocol] = []
            tasks.forEach { _, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadTasks() {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTasks = tasks[taskType] else { return 0 }
        return currentTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return getConfiguredTaskCellConstraints(for: indexPath)
        return getConfiguredTaskCellStack(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionsTypesPosition[section]
        if taskType == .important {
            title = "Important"
        } else {
            title = "Current"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceTaskType = sectionsTypesPosition[sourceIndexPath.section]
        let movingItem = tasks[sourceTaskType]?.remove(at: sourceIndexPath.row)
        
        let destinationTaskType = sectionsTypesPosition[destinationIndexPath.section]
        tasks[destinationTaskType]?.insert(movingItem!, at: destinationIndexPath.row)
        
        if sourceTaskType != destinationTaskType {
            tasks[destinationTaskType]![destinationIndexPath.row].type = destinationTaskType
        }
        
        tableView.reloadData()
    }
    
    private func getConfiguredTaskCellConstraints(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else { return cell }
        
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        textLabel?.text = currentTask.title
        
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    private func getConfiguredTaskCellStack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else { return cell }
        
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String{
        var resultSymbol: String
        switch status {
        case .planned: resultSymbol = "\u{25CB}"
        case .completed: resultSymbol = "\u{25C9}"
        }
        return resultSymbol
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //check if the task exists
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else { return }
        
        //check if the task is not completeed
        if tasks[taskType]?[indexPath.row].status == .planned {
            tasks[taskType]?[indexPath.row].status  = .completed
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else { return nil }
        
        //change to .planned
        let actionSwipe = UIContextualAction(style: .normal, title: "Planned") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        //move to EditScreen
        let actionEdit = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            let destination = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            //transfer of values
            destination.taskText = self.tasks[taskType]![indexPath.row].title
            destination.taskType = self.tasks[taskType]![indexPath.row].type
            destination.taskStatus = self.tasks[taskType]![indexPath.row].status
            
            // передача обработчика для сохранения задачи transfer of handler to save task
            destination.doAfterEdit = {[unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            //переход к экрану редактирования
            self.navigationController?.pushViewController(destination, animated: true)
        }
        actionEdit.backgroundColor = .darkGray
        
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
        actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipe, actionEdit])
        } else {
        actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEdit])
        }

        return actionsConfiguration
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = {[unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()    
            }
        }
    }
}


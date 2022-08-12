//
//  TasksStorage.swift
//  ToDoManager
//
//  Created by Nataliya Lazouskaya on 9.08.22.
//

import Foundation

protocol TasksStorageProtocol {
    func saveTasks(_ tasks: [TaskProtocol])
    func loadTasks() -> [TaskProtocol]
}

class TasksStorage: TasksStorageProtocol{
    func saveTasks(_ tasks: [TaskProtocol]) {
    }
    
    func loadTasks() -> [TaskProtocol] {
        let tasks: [TaskProtocol] = [Task(title: "Buy coffee", type: .normal, status: .planned),
                                     Task(title: "Walk 10000 steps", type: .important, status: .planned),
                                     Task(title: "Iron the jacket", type: .normal, status: .planned),
                                     Task(title: "Water the greens", type: .normal, status: .completed),
                                     Task(title: "Cook food", type: .normal, status: .planned),
                                     Task(title: "Try to feel myself comfortable during this period of time", type: .important, status: .planned)]
        
        return tasks
    }
}

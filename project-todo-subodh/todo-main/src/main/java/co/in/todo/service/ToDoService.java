package co.in.todo.service;

import java.util.List;

import co.in.todo.domain.ToDo;

public interface ToDoService {

	ToDo createToDo(ToDo toDo);

	ToDo updateToDo(ToDo toDo);

	ToDo getToDoByID(Long id);

	List<ToDo> getAllToDos();

	void deleteToDoById(Long id);

}

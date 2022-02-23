package co.in.todo.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;

import co.in.todo.domain.ToDo;
import co.in.todo.repository.ToDoRepository;
import co.in.todo.service.ToDoService;

@Service
public class ToDoServiceImpl implements ToDoService {
	
	private final ToDoRepository toDoRepository;
	
	public ToDoServiceImpl(ToDoRepository toDoRepository) {
		this.toDoRepository = toDoRepository;
	}

	@Override
	public ToDo createToDo(ToDo toDo) {
		return toDoRepository.save(toDo);
	}

	@Override
	public ToDo updateToDo(ToDo toDo) {
		return toDoRepository.save(toDo);
	}

	@Override
	public ToDo getToDoByID(Long id) {
		return toDoRepository.getById(id);
	}

	@Override
	public List<ToDo> getAllToDos() {
		return toDoRepository.findAll();
	}

	@Override
	public void deleteToDoById(Long id) {
		toDoRepository.deleteById(id);
	}

}

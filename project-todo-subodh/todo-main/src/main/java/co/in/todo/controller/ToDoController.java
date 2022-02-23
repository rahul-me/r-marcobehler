package co.in.todo.controller;

import java.util.List;

import javax.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import co.in.todo.common.ApiResponse;
import co.in.todo.common.Constants;
import co.in.todo.domain.ToDo;
import co.in.todo.service.ToDoService;

@RestController
@RequestMapping("/todo")
public class ToDoController {
	
	private final ToDoService toDoService;
	
	public ToDoController(ToDoService toDoService){
		this.toDoService = toDoService;
	}

	@PostMapping
	public ApiResponse createToDo(@RequestBody @Valid ToDo toDoDTO) {

		ToDo toDo = toDoService.createToDo(toDoDTO);
		return new ApiResponse(HttpStatus.CREATED, HttpStatus.CREATED.value(), Constants.SUCCESSFULLY_FETCHED_DATA,
				toDo);
	}
	
	@PutMapping
	public ApiResponse updateToDo(@RequestBody @Valid ToDo toDoDTO) {

		ToDo toDo = toDoService.updateToDo(toDoDTO);
		return new ApiResponse(HttpStatus.OK, HttpStatus.OK.value(), Constants.SUCCESSFULLY_UPDATED_DATA,
				toDo);
	}
	
	@GetMapping("/{id}")
	public ApiResponse getToDoById(@PathVariable Long id) {

		ToDo toDo = toDoService.getToDoByID(id);
		
		return new ApiResponse(HttpStatus.OK, HttpStatus.OK.value(), Constants.SUCCESSFULLY_FETCHED_DATA,
				toDo);
	}
	
	@GetMapping
	public ApiResponse getAllToDo() {

		List<ToDo> toDos = toDoService.getAllToDos();
		
		return new ApiResponse(HttpStatus.OK, HttpStatus.OK.value(), Constants.SUCCESSFULLY_FETCHED_DATA,
				toDos);
	}
	
	@DeleteMapping("/{id}")
	public ApiResponse deleteToDo(@PathVariable Long id) {

		toDoService.deleteToDoById(id);
		
		return new ApiResponse(HttpStatus.OK, HttpStatus.OK.value(), Constants.SUCCESSFULLY_DELETED_DATA,
				"");
	}
}

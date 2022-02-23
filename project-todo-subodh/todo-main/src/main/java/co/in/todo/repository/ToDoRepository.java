package co.in.todo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import co.in.todo.domain.ToDo;

@Repository
public interface ToDoRepository extends JpaRepository<ToDo, Long>{

}

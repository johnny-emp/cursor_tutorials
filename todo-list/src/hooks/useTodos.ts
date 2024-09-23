"use client";

import { useState, useEffect, useCallback } from 'react';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
  deadline: Date;
}

export const useTodos = () => {
    const [todos, setTodos] = useState<Todo[]>(() => {
      const storedTodos = localStorage.getItem('todos');
      return storedTodos ? JSON.parse(storedTodos, (key, value) => 
        key === 'deadline' ? new Date(value) : value
      ) : [];
    });
  
    useEffect(() => {
      const storedTodos = localStorage.getItem('todos');
      if (storedTodos) {
        setTodos(JSON.parse(storedTodos, (key, value) => 
          key === 'deadline' ? new Date(value) : value
        ));
      }
    }, []);
  
    useEffect(() => {
      localStorage.setItem('todos', JSON.stringify(todos));
    }, [todos]);
  
    const addTodo = useCallback((newTodoText: string, deadline: Date) => {
      if (newTodoText.trim() !== '') {
        const updatedTodos = [...todos, { id: Date.now(), text: newTodoText, completed: false, deadline }];
        setTodos(updatedTodos);
      }
    }, [todos]);
  
    const toggleTodo = useCallback((id: number) => {
      const updatedTodos = todos.map(todo =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      );
      setTodos(updatedTodos);
    }, [todos]);
  
    const deleteTodo = useCallback((id: number) => {
      const updatedTodos = todos.filter(todo => todo.id !== id);
      setTodos(updatedTodos);
    }, [todos]);
  
    return { todos, addTodo, toggleTodo, deleteTodo };
  };
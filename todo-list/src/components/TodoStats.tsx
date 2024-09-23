"use client";

import React, { useState, useEffect } from 'react';
import { useTodoContext } from '../context/TodoContext';

const TodoStats: React.FC = () => {
  const { todos } = useTodoContext();
  const [completedTodos, setCompletedTodos] = useState(0);
  const [incompleteTodos, setIncompleteTodos] = useState(0);

  useEffect(() => {
    const completed = todos.filter((todo: { completed: boolean }) => todo.completed).length;
    setCompletedTodos(completed);
    setIncompleteTodos(todos.length - completed);
  }, [todos]);

  return (
    <div className="flex justify-center items-center space-x-4 mt-8 mb-4">
      <div className="bg-white p-4 rounded-lg shadow-md w-48">
        <h2 className="text-lg font-semibold mb-2">Completed</h2>
        <span className="text-3xl font-bold text-green-600">{completedTodos}</span>
      </div>
      <div className="bg-white p-4 rounded-lg shadow-md w-48">
        <h2 className="text-lg font-semibold mb-2">Incomplete</h2>
        <span className="text-3xl font-bold text-red-600">{incompleteTodos}</span>
      </div>
    </div>
  );
};

export default TodoStats;

"use client";

import React, { createContext, useContext } from 'react';
import { useTodos } from '../hooks/useTodos';

const TodoContext = createContext();

export const TodoProvider = ({ children }) => {
  const todoData = useTodos();

  return (
    <TodoContext.Provider value={todoData}>
      {children}
    </TodoContext.Provider>
  );
};

export const useTodoContext = () => {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error('useTodoContext must be used within a TodoProvider');
  }
  return context;
};

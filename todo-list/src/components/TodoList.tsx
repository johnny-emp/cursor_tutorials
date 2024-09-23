"use client";

import React, { useState } from 'react';
import Todo from './Todo';
import { useTodoContext } from '../context/TodoContext';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';

const TodoList: React.FC = () => {
  const { todos, addTodo, toggleTodo, deleteTodo } = useTodoContext();
  const [newTodo, setNewTodo] = useState('');
  const [deadline, setDeadline] = useState<Date | null>(null);

  const handleAddTodo = () => {
    if (newTodo.trim() !== '' && deadline) {
      addTodo(newTodo, deadline);
      setNewTodo('');
      setDeadline(null);
    }
  };

  const sortedTodos = [...todos].sort((a, b) => a.deadline.getTime() - b.deadline.getTime());

  return (
    <div className="max-w-md mx-auto mt-8 p-6 bg-[var(--background-color)] rounded-xl shadow-lg" style={{ boxShadow: '20px 20px 60px var(--light-gray), -20px -20px 60px #ffffff' }}>
      <div className="bg-white p-6 rounded-lg shadow-inner mb-6">
        <div className="flex flex-col mb-4">
          <input
            type="text"
            className="p-2 border border-[var(--light-gray)] rounded-t focus:outline-none focus:ring-2 focus:ring-[var(--primary-color)]"
            value={newTodo}
            onChange={(e) => setNewTodo(e.target.value)}
            placeholder="Add a new todo"
          />
          <DatePicker
            selected={deadline}
            onChange={(date: Date | null) => setDeadline(date)}
            showTimeSelect
            timeFormat="HH:mm"
            timeIntervals={15}
            timeCaption="Time"
            dateFormat="MMMM d, yyyy h:mm aa"
            className="w-full p-2 border border-[var(--light-gray)] border-t-0 focus:outline-none focus:ring-2 focus:ring-[var(--primary-color)]"
            placeholderText="Select deadline (date and time)"
          />
          <button
            className="bg-[var(--primary-color)] text-white px-4 py-2 rounded-b hover:bg-[var(--secondary-color)] transition duration-300 ease-in-out"
            onClick={handleAddTodo}
          >
            Add
          </button>
        </div>
        <ul className="space-y-3">
          {sortedTodos.map(todo => (
              <Todo key={todo.id} {...todo} toggleTodo={toggleTodo} deleteTodo={deleteTodo} />
          ))}
        </ul>
      </div>
    </div>
  );
};

export default TodoList;

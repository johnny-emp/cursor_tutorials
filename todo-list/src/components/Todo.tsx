import React from 'react';
import { motion } from 'framer-motion';

interface TodoProps {
  id: number;
  text: string;
  completed: boolean;
  deadline: Date;
  toggleTodo: (id: number) => void;
  deleteTodo: (id: number) => void;
}

const Todo: React.FC<TodoProps> = ({ id, text, completed, deadline, toggleTodo, deleteTodo }) => {
  const isDeadlineClose = () => {
    const now = new Date();
    const timeDiff = deadline.getTime() - now.getTime();
    const hoursDiff = timeDiff / (1000 * 3600);
    return hoursDiff <= 10 && hoursDiff > 0;
  };

  const isDeadlinePassed = () => {
    return new Date() > deadline;
  };

  const getBgColor = () => {
    if (isDeadlinePassed()) {
      return completed ? 'bg-gray-200' : 'bg-red-100';
    }
    return isDeadlineClose() ? 'bg-yellow-100' : 'bg-white';
  };

  const bgColor = getBgColor();

  return (
    <motion.li
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 10 }}
      className={`flex items-center mb-4 p-4 ${bgColor} border border-gray-200 rounded-lg shadow-sm`}
    >
      <motion.input
        type="checkbox"
        checked={completed}
        onChange={() => toggleTodo(id)}
        className="form-checkbox h-5 w-5 text-blue-600 transition duration-150 ease-in-out mr-3"
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
      />
      <div className="flex-grow">
        <motion.span
          className={`text-lg ${
            completed ? 'line-through text-gray-400' : isDeadlinePassed() ? 'text-red-600' : 'text-gray-700'
          }`}
          animate={{ opacity: completed ? 0.6 : 1 }}
        >
          {text}
        </motion.span>
        {deadline && (
          <div className="text-sm text-gray-500">
            Deadline: {deadline.toLocaleString()}
          </div>
        )}
        <div className="text-sm text-gray-500">
          Status: {completed ? 'Completed' : 'Pending'}
        </div>
      </div>
      <motion.button
        className="bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-2 px-4 rounded transition duration-300 ease-in-out"
        onClick={() => deleteTodo(id)}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        Delete
      </motion.button>
    </motion.li>
  );
};

export default Todo;

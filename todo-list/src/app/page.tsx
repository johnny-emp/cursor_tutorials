import TodoList from '../components/TodoList';
import TodoStats from '../components/TodoStats';
import Image from "next/image";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { TodoProvider } from '../context/TodoContext';

export default function Home() {
  return (
    <TodoProvider>
      <div className="flex flex-col min-h-screen">
        <Header />

        <main className="flex-grow">
          <TodoStats />
          <TodoList />
        </main>

        <Footer />
      </div>
    </TodoProvider>
  );
}

import { Bell, User, School } from "lucide-react";

interface AppHeaderProps {
  title?: string;
}

export default function AppHeader({ title = "College Campus" }: AppHeaderProps) {
  return (
    <header className="bg-primary text-white px-4 py-3 shadow-lg sticky top-0 z-50">
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <School className="w-6 h-6" />
          <h1 className="text-lg font-medium">{title}</h1>
        </div>
        <div className="flex items-center space-x-2">
          <button className="p-1 hover:bg-white/10 rounded-full transition-colors">
            <Bell className="w-5 h-5" />
          </button>
          <button className="p-1 hover:bg-white/10 rounded-full transition-colors">
            <User className="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>
  );
}

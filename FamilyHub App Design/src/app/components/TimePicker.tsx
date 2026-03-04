import { useState } from "react";
import { Clock } from "lucide-react";
import { Button } from "@/app/components/ui/button";
import { Input } from "@/app/components/ui/input";
import { Popover, PopoverContent, PopoverTrigger } from "@/app/components/ui/popover";

interface TimePickerProps {
  value: string;
  onChange: (time: string) => void;
}

export function TimePicker({ value, onChange }: TimePickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [hours, setHours] = useState(value.split(":")[0] || "12");
  const [minutes, setMinutes] = useState(value.split(":")[1] || "00");
  const [isPM, setIsPM] = useState(parseInt(hours) >= 12);

  const formatTime = (h: string, m: string) => {
    const hour = parseInt(h);
    const formattedHour = hour.toString().padStart(2, "0");
    const formattedMinute = m.padStart(2, "0");
    return `${formattedHour}:${formattedMinute}`;
  };

  const handleHourClick = (hour: number) => {
    const hour24 = isPM && hour !== 12 ? hour + 12 : !isPM && hour === 12 ? 0 : hour;
    const newHours = hour24.toString().padStart(2, "0");
    setHours(newHours);
    onChange(formatTime(newHours, minutes));
  };

  const handleMinuteClick = (minute: number) => {
    const newMinutes = minute.toString().padStart(2, "0");
    setMinutes(newMinutes);
    onChange(formatTime(hours, newMinutes));
  };

  const togglePeriod = () => {
    const newIsPM = !isPM;
    setIsPM(newIsPM);
    const currentHour = parseInt(hours);
    const newHour = newIsPM
      ? currentHour < 12
        ? currentHour + 12
        : currentHour
      : currentHour >= 12
      ? currentHour - 12
      : currentHour;
    const newHours = newHour.toString().padStart(2, "0");
    setHours(newHours);
    onChange(formatTime(newHours, minutes));
  };

  const displayHour = () => {
    const h = parseInt(hours);
    if (h === 0) return 12;
    if (h > 12) return h - 12;
    return h;
  };

  const hourNumbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  const minuteNumbers = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  return (
    <Popover open={isOpen} onOpenChange={setIsOpen}>
      <PopoverTrigger asChild>
        <button
          type="button"
          className="flex h-10 w-full items-center justify-start rounded-md border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 transition-colors hover:border-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <Clock className="mr-2 h-4 w-4 text-gray-500" />
          {value || "Select time"}
        </button>
      </PopoverTrigger>
      <PopoverContent className="w-80 p-4" align="start">
        <div className="space-y-4">
          {/* Current Time Display */}
          <div className="flex items-center justify-center gap-2 pb-3 border-b">
            <div className="text-center">
              <div className="text-4xl font-bold text-gray-900">
                {displayHour().toString().padStart(2, "0")}
              </div>
            </div>
            <div className="text-4xl font-bold text-gray-900">:</div>
            <div className="text-center">
              <div className="text-4xl font-bold text-gray-900">
                {minutes.padStart(2, "0")}
              </div>
            </div>
            <div className="flex flex-col gap-1 ml-2">
              <button
                onClick={() => {
                  setIsPM(false);
                  const currentHour = parseInt(hours);
                  if (currentHour >= 12) {
                    const newHour = currentHour - 12;
                    const newHours = newHour.toString().padStart(2, "0");
                    setHours(newHours);
                    onChange(formatTime(newHours, minutes));
                  }
                }}
                className={`px-2 py-1 text-xs font-semibold rounded transition-colors ${
                  !isPM
                    ? "bg-blue-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                AM
              </button>
              <button
                onClick={() => {
                  setIsPM(true);
                  const currentHour = parseInt(hours);
                  if (currentHour < 12) {
                    const newHour = currentHour + 12;
                    const newHours = newHour.toString().padStart(2, "0");
                    setHours(newHours);
                    onChange(formatTime(newHours, minutes));
                  }
                }}
                className={`px-2 py-1 text-xs font-semibold rounded transition-colors ${
                  isPM
                    ? "bg-blue-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                PM
              </button>
            </div>
          </div>

          {/* Hour Selection */}
          <div>
            <div className="text-xs font-semibold text-gray-500 mb-2">Hours</div>
            <div className="grid grid-cols-6 gap-1">
              {hourNumbers.map((hour) => {
                const hour24 =
                  isPM && hour !== 12 ? hour + 12 : !isPM && hour === 12 ? 0 : hour;
                const isSelected = parseInt(hours) === hour24;
                return (
                  <button
                    key={hour}
                    onClick={() => handleHourClick(hour)}
                    className={`p-2 text-sm font-medium rounded transition-colors ${
                      isSelected
                        ? "bg-blue-600 text-white"
                        : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                    }`}
                  >
                    {hour}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Minute Selection */}
          <div>
            <div className="text-xs font-semibold text-gray-500 mb-2">Minutes</div>
            <div className="grid grid-cols-6 gap-1">
              {minuteNumbers.map((minute) => {
                const isSelected = parseInt(minutes) === minute;
                return (
                  <button
                    key={minute}
                    onClick={() => handleMinuteClick(minute)}
                    className={`p-2 text-sm font-medium rounded transition-colors ${
                      isSelected
                        ? "bg-blue-600 text-white"
                        : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                    }`}
                  >
                    {minute.toString().padStart(2, "0")}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Done Button */}
          <Button
            onClick={() => setIsOpen(false)}
            className="w-full"
          >
            Done
          </Button>
        </div>
      </PopoverContent>
    </Popover>
  );
}
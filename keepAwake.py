import time
import random
import pyautogui

# Install first:
# pip install pyautogui

hours = input("Enter the time in hours: ")

interval = 60  # seconds, same as 60000 ms

def tap_numlock():
    pyautogui.press("numlock")
    time.sleep(0.1)
    pyautogui.press("numlock")
    time.sleep(0.1)

def toggle_alt_tab(n):
    for _ in range(n + 1):
        pyautogui.hotkey("alt", "tab")
        time.sleep(random.uniform(0.05, 0.3))
        pyautogui.hotkey("alt", "tab")
        time.sleep(random.uniform(0.01, 0.2))

def movement_up_down(n):
    for _ in range(n):
        pyautogui.press("up")
        time.sleep(random.uniform(0.01, 0.2))

    for _ in range(n):
        pyautogui.press("down")
        time.sleep(random.uniform(0.01, 0.2))

def right_click_and_escape():
    pyautogui.rightClick()
    time.sleep(0.1)
    pyautogui.press("esc")
    time.sleep(0.1)

def move_mouse_random():
    screen_width, screen_height = pyautogui.size()

    x = random.randint(0, screen_width - 1)
    y = random.randint(0, screen_height - 1)

    print(f"{x}, {y}")

    duration = random.uniform(1, 4)
    pyautogui.moveTo(x, y, duration=duration)

    right_click_and_escape()

try:
    hours_float = float(hours)
    total_runs = int((hours_float * 60 * 60) / interval)

    for i in range(1, total_runs + 1):
        print(f"{i}/{total_runs}")

        tap_numlock()
        toggle_alt_tab(2)
        movement_up_down(random.randint(3, 9))
        move_mouse_random()

        time.sleep(interval)

except ValueError:
    print("Invalid input. Please enter a numeric value for hours.")

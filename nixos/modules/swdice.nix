{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.swdice;
  
  # Python application for the Star Wars dice roller
  swdice-app = pkgs.python3Packages.buildPythonApplication {
    pname = "swdice";
    version = "1.0.0";
    
    src = pkgs.runCommand "swdice-src" {} ''
      mkdir -p $out/swdice
      cat > $out/setup.py << EOF
      from setuptools import setup

      setup(
          name="swdice",
          version="1.0.0",
          packages=["swdice"],
          install_requires=["rich"],
          entry_points={
              "console_scripts": [
                  "swdice=swdice.swdice:main",
              ],
          },
      )
      EOF

      touch $out/swdice/__init__.py
      
      cat > $out/swdice/swdice.py << EOF
      #!/usr/bin/env python3
      
      import random
      import argparse
      import json
      import os
      import sys
      import math
      from enum import Enum, auto
      from typing import Dict, List, Tuple, Optional, Set, Union
      from dataclasses import dataclass
      import time
      
      try:
          from rich.console import Console
          from rich.panel import Panel
          from rich.table import Table
          from rich.text import Text
          from rich.prompt import Prompt, Confirm
          from rich.layout import Layout
          from rich import box
          from rich.columns import Columns
          HAS_RICH = True
      except ImportError:
          HAS_RICH = False
          print("Rich library not available. Using plain text output.")
      
      # Configuration
      CONFIG_DIR = os.path.expanduser("~/.config/swdice")
      HISTORY_FILE = os.path.join(CONFIG_DIR, "history.json")
      PRESETS_FILE = os.path.join(CONFIG_DIR, "presets.json")
      
      # Create config directory if it doesn't exist
      os.makedirs(CONFIG_DIR, exist_ok=True)
      
      # Dice symbols
      class Symbol(Enum):
          SUCCESS = auto()
          FAILURE = auto()
          ADVANTAGE = auto()
          THREAT = auto()
          TRIUMPH = auto()
          DESPAIR = auto()
          LIGHT = auto()
          DARK = auto()
          BLANK = auto()
      
      # Die types
      class DieType(Enum):
          BOOST = "Boost"         # Blue d6
          ABILITY = "Ability"     # Green d8
          PROFICIENCY = "Proficiency"  # Yellow d12
          SETBACK = "Setback"     # Black d6
          DIFFICULTY = "Difficulty"    # Purple d8
          CHALLENGE = "Challenge"      # Red d12
          FORCE = "Force"         # White d12
      
      # Die colors for rich display
      DIE_COLORS = {
          DieType.BOOST: "bright_blue",
          DieType.ABILITY: "green",
          DieType.PROFICIENCY: "yellow",
          DieType.SETBACK: "bright_black",
          DieType.DIFFICULTY: "purple",
          DieType.CHALLENGE: "red",
          DieType.FORCE: "white",
      }
      
      # Symbol representation
      SYMBOL_CHARS = {
          Symbol.SUCCESS: "✓",
          Symbol.FAILURE: "✗",
          Symbol.ADVANTAGE: "a",
          Symbol.THREAT: "t",
          Symbol.TRIUMPH: "⚜",
          Symbol.DESPAIR: "⚠",
          Symbol.LIGHT: "○",
          Symbol.DARK: "●",
          Symbol.BLANK: " ",
      }
      
      # Die face configurations
      DIE_FACES = {
          DieType.BOOST: [
              [],
              [],
              [Symbol.SUCCESS],
              [Symbol.SUCCESS, Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE, Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE]
          ],
          DieType.ABILITY: [
              [],
              [Symbol.SUCCESS],
              [Symbol.SUCCESS],
              [Symbol.SUCCESS, Symbol.SUCCESS],
              [Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE],
              [Symbol.SUCCESS, Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE, Symbol.ADVANTAGE]
          ],
          DieType.PROFICIENCY: [
              [],
              [Symbol.SUCCESS],
              [Symbol.SUCCESS],
              [Symbol.SUCCESS, Symbol.SUCCESS],
              [Symbol.SUCCESS, Symbol.SUCCESS],
              [Symbol.ADVANTAGE],
              [Symbol.SUCCESS, Symbol.ADVANTAGE],
              [Symbol.SUCCESS, Symbol.ADVANTAGE],
              [Symbol.SUCCESS, Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE, Symbol.ADVANTAGE],
              [Symbol.ADVANTAGE, Symbol.ADVANTAGE],
              [Symbol.TRIUMPH]
          ],
          DieType.SETBACK: [
              [],
              [],
              [Symbol.FAILURE],
              [Symbol.FAILURE],
              [Symbol.THREAT],
              [Symbol.THREAT]
          ],
          DieType.DIFFICULTY: [
              [],
              [Symbol.FAILURE],
              [Symbol.FAILURE, Symbol.FAILURE],
              [Symbol.THREAT],
              [Symbol.THREAT],
              [Symbol.THREAT],
              [Symbol.THREAT, Symbol.THREAT],
              [Symbol.FAILURE, Symbol.THREAT]
          ],
          DieType.CHALLENGE: [
              [],
              [Symbol.FAILURE],
              [Symbol.FAILURE],
              [Symbol.FAILURE, Symbol.FAILURE],
              [Symbol.FAILURE, Symbol.FAILURE],
              [Symbol.THREAT],
              [Symbol.THREAT],
              [Symbol.FAILURE, Symbol.THREAT],
              [Symbol.FAILURE, Symbol.THREAT],
              [Symbol.THREAT, Symbol.THREAT],
              [Symbol.THREAT, Symbol.THREAT],
              [Symbol.DESPAIR]
          ],
          DieType.FORCE: [
              [Symbol.DARK],
              [Symbol.DARK],
              [Symbol.DARK],
              [Symbol.DARK],
              [Symbol.DARK],
              [Symbol.DARK],
              [Symbol.DARK, Symbol.DARK],
              [Symbol.LIGHT],
              [Symbol.LIGHT],
              [Symbol.LIGHT, Symbol.LIGHT],
              [Symbol.LIGHT, Symbol.LIGHT],
              [Symbol.LIGHT, Symbol.LIGHT]
          ]
      }
      
      @dataclass
      class DicePool:
          boost: int = 0
          ability: int = 0
          proficiency: int = 0
          setback: int = 0
          difficulty: int = 0
          challenge: int = 0
          force: int = 0
          
          def is_empty(self) -> bool:
              return (self.boost == 0 and self.ability == 0 and self.proficiency == 0 and
                      self.setback == 0 and self.difficulty == 0 and self.challenge == 0 and
                      self.force == 0)
          
          def to_dict(self) -> Dict:
              return {
                  "boost": self.boost,
                  "ability": self.ability,
                  "proficiency": self.proficiency,
                  "setback": self.setback,
                  "difficulty": self.difficulty,
                  "challenge": self.challenge,
                  "force": self.force
              }
          
          @classmethod
          def from_dict(cls, data: Dict) -> 'DicePool':
              return cls(
                  boost=data.get("boost", 0),
                  ability=data.get("ability", 0),
                  proficiency=data.get("proficiency", 0),
                  setback=data.get("setback", 0),
                  difficulty=data.get("difficulty", 0),
                  challenge=data.get("challenge", 0),
                  force=data.get("force", 0)
              )
              
          def add_dice(self, die_type: DieType, count: int = 1):
              if die_type == DieType.BOOST:
                  self.boost += count
              elif die_type == DieType.ABILITY:
                  self.ability += count
              elif die_type == DieType.PROFICIENCY:
                  self.proficiency += count
              elif die_type == DieType.SETBACK:
                  self.setback += count
              elif die_type == DieType.DIFFICULTY:
                  self.difficulty += count
              elif die_type == DieType.CHALLENGE:
                  self.challenge += count
              elif die_type == DieType.FORCE:
                  self.force += count
      
      @dataclass
      class RollResult:
          success: int = 0
          advantage: int = 0
          triumph: int = 0
          despair: int = 0
          light: int = 0
          dark: int = 0
          dice_pool: DicePool = None
          dice_results: List[Tuple[DieType, List[Symbol]]] = None
          timestamp: float = None
          description: str = ""
          
          def to_dict(self) -> Dict:
              return {
                  "success": self.success,
                  "advantage": self.advantage,
                  "triumph": self.triumph,
                  "despair": self.despair,
                  "light": self.light, 
                  "dark": self.dark,
                  "dice_pool": self.dice_pool.to_dict() if self.dice_pool else None,
                  "timestamp": self.timestamp,
                  "description": self.description
              }
          
          @classmethod
          def from_dict(cls, data: Dict) -> 'RollResult':
              result = cls(
                  success=data.get("success", 0),
                  advantage=data.get("advantage", 0),
                  triumph=data.get("triumph", 0),
                  despair=data.get("despair", 0),
                  light=data.get("light", 0),
                  dark=data.get("dark", 0),
                  dice_pool=DicePool.from_dict(data.get("dice_pool", {})) if data.get("dice_pool") else None,
                  timestamp=data.get("timestamp", time.time()),
                  description=data.get("description", "")
              )
              return result
      
      class DiceRoller:
          def __init__(self):
              self.history: List[RollResult] = []
              self.presets: Dict[str, DicePool] = {}
              self.load_history()
              self.load_presets()
              
          def load_history(self):
              if os.path.exists(HISTORY_FILE):
                  try:
                      with open(HISTORY_FILE, 'r') as f:
                          data = json.load(f)
                          self.history = [RollResult.from_dict(item) for item in data]
                  except Exception as e:
                      print(f"Error loading history: {e}")
          
          def save_history(self):
              try:
                  with open(HISTORY_FILE, 'w') as f:
                      json.dump([r.to_dict() for r in self.history], f)
              except Exception as e:
                  print(f"Error saving history: {e}")
          
          def load_presets(self):
              if os.path.exists(PRESETS_FILE):
                  try:
                      with open(PRESETS_FILE, 'r') as f:
                          data = json.load(f)
                          self.presets = {name: DicePool.from_dict(pool_data) 
                                         for name, pool_data in data.items()}
                  except Exception as e:
                      print(f"Error loading presets: {e}")
          
          def save_presets(self):
              try:
                  with open(PRESETS_FILE, 'w') as f:
                      json.dump({name: pool.to_dict() for name, pool in self.presets.items()}, f)
              except Exception as e:
                  print(f"Error saving presets: {e}")
          
          def roll_die(self, die_type: DieType) -> List[Symbol]:
              faces = DIE_FACES[die_type]
              result = random.choice(faces)
              return result
          
          def roll_dice_pool(self, pool: DicePool, description: str = "") -> RollResult:
              if pool.is_empty():
                  return RollResult(dice_pool=pool, timestamp=time.time(), description=description)
              
              result = RollResult(dice_pool=pool, timestamp=time.time(), description=description)
              result.dice_results = []
              
              # Roll boost dice
              for _ in range(pool.boost):
                  symbols = self.roll_die(DieType.BOOST)
                  result.dice_results.append((DieType.BOOST, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll ability dice
              for _ in range(pool.ability):
                  symbols = self.roll_die(DieType.ABILITY)
                  result.dice_results.append((DieType.ABILITY, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll proficiency dice
              for _ in range(pool.proficiency):
                  symbols = self.roll_die(DieType.PROFICIENCY)
                  result.dice_results.append((DieType.PROFICIENCY, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll setback dice
              for _ in range(pool.setback):
                  symbols = self.roll_die(DieType.SETBACK)
                  result.dice_results.append((DieType.SETBACK, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll difficulty dice
              for _ in range(pool.difficulty):
                  symbols = self.roll_die(DieType.DIFFICULTY)
                  result.dice_results.append((DieType.DIFFICULTY, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll challenge dice
              for _ in range(pool.challenge):
                  symbols = self.roll_die(DieType.CHALLENGE)
                  result.dice_results.append((DieType.CHALLENGE, symbols))
                  self._count_symbols(result, symbols)
              
              # Roll force dice
              for _ in range(pool.force):
                  symbols = self.roll_die(DieType.FORCE)
                  result.dice_results.append((DieType.FORCE, symbols))
                  self._count_symbols(result, symbols, is_force=True)
              
              # Add to history
              self.history.append(result)
              self.save_history()
              
              return result
          
          def _count_symbols(self, result: RollResult, symbols: List[Symbol], is_force: bool = False):
              if is_force:
                  for symbol in symbols:
                      if symbol == Symbol.LIGHT:
                          result.light += 1
                      elif symbol == Symbol.DARK:
                          result.dark += 1
              else:
                  for symbol in symbols:
                      if symbol == Symbol.SUCCESS:
                          result.success += 1
                      elif symbol == Symbol.FAILURE:
                          result.success -= 1
                      elif symbol == Symbol.ADVANTAGE:
                          result.advantage += 1
                      elif symbol == Symbol.THREAT:
                          result.advantage -= 1
                      elif symbol == Symbol.TRIUMPH:
                          result.triumph += 1
                          result.success += 1  # Triumph also counts as a success
                      elif symbol == Symbol.DESPAIR:
                          result.despair += 1
                          result.success -= 1  # Despair also counts as a failure
      
      class DiceUI:
          def __init__(self):
              self.roller = DiceRoller()
              self.console = Console() if HAS_RICH else None
          
          def display_result(self, result: RollResult):
              if not HAS_RICH:
                  self._display_result_plain(result)
                  return
              
              layout = Layout()
              layout.split(
                  Layout(name="header", size=3),
                  Layout(name="main"),
                  Layout(name="footer", size=3)
              )
              
              # Header
              title = "Star Wars Narrative Dice System"
              if result.description:
                  title += f": {result.description}"
              layout["header"].update(Panel(Text(title, justify="center", style="bold white on blue")))
              
              # Main content
              main_layout = Layout()
              main_layout.split_row(
                  Layout(name="dice", ratio=2),
                  Layout(name="result", ratio=1)
              )
              
              # Dice results
              if result.dice_results:
                  dice_panels = []
                  for die_type, symbols in result.dice_results:
                      color = DIE_COLORS[die_type]
                      symbol_str = " ".join([SYMBOL_CHARS[s] for s in symbols]) if symbols else "-"
                      dice_panels.append(
                          Panel(
                              Text(symbol_str, justify="center"),
                              title=f"{die_type.value}",
                              border_style=color,
                              padding=(1, 2)
                          )
                      )
                  
                  # Arrange dice in a grid-like structure
                  cols = 3  # Number of columns
                  rows = math.ceil(len(dice_panels) / cols)
                  
                  grouped_panels = []
                  for i in range(rows):
                      start_idx = i * cols
                      end_idx = min(start_idx + cols, len(dice_panels))
                      row_panels = dice_panels[start_idx:end_idx]
                      grouped_panels.append(Columns(row_panels))
                  
                  main_layout["dice"].update(Panel(
                      Columns(grouped_panels, equal=True, expand=True),
                      title="Dice Results",
                      border_style="cyan"
                  ))
              else:
                  main_layout["dice"].update(Panel(
                      Text("No dice rolled", justify="center"),
                      title="Dice Results",
                      border_style="cyan"
                  ))
              
              # Roll results
              result_table = Table(box=box.ROUNDED)
              result_table.add_column("Outcome", style="cyan")
              result_table.add_column("Value", style="green")
              
              net_success = result.success
              result_table.add_row("Net Success", f"{net_success:+d}" if net_success != 0 else "0")
              
              net_advantage = result.advantage
              result_table.add_row("Net Advantage", f"{net_advantage:+d}" if net_advantage != 0 else "0")
              
              if result.triumph > 0:
                  result_table.add_row("Triumph", str(result.triumph))
              
              if result.despair > 0:
                  result_table.add_row("Despair", str(result.despair))
              
              if result.light > 0:
                  result_table.add_row("Light Side", str(result.light))
              
              if result.dark > 0:
                  result_table.add_row("Dark Side", str(result.dark))
              
              main_layout["result"].update(Panel(result_table, title="Results", border_style="green"))
              
              layout["main"].update(main_layout)
              
              # Footer
              pool = result.dice_pool
              pool_str = f"Dice Pool: "
              if pool:
                  parts = []
                  if pool.boost > 0: parts.append(f"[bright_blue]{pool.boost}B[/]")
                  if pool.ability > 0: parts.append(f"[green]{pool.ability}A[/]")
                  if pool.proficiency > 0: parts.append(f"[yellow]{pool.proficiency}P[/]")
                  if pool.setback > 0: parts.append(f"[bright_black]{pool.setback}S[/]")
                  if pool.difficulty > 0: parts.append(f"[purple]{pool.difficulty}D[/]")
                  if pool.challenge > 0: parts.append(f"[red]{pool.challenge}C[/]")
                  if pool.force > 0: parts.append(f"[white]{pool.force}F[/]")
                  pool_str += " ".join(parts)
              else:
                  pool_str += "None"
              
              layout["footer"].update(Panel(Text(pool_str, justify="center")))
              
              # Render the layout
              self.console.print(layout)
          
          def _display_result_plain(self, result: RollResult):
              print("\n===== Star Wars Narrative Dice System =====")
              if result.description:
                  print(f"Roll: {result.description}")
              
              if result.dice_results:
                  print("\nDice Results:")
                  for die_type, symbols in result.dice_results:
                      symbol_str = " ".join([SYMBOL_CHARS[s] for s in symbols]) if symbols else "-"
                      print(f"  {die_type.value}: {symbol_str}")
              
              print("\nOutcomes:")
              net_success = result.success
              print(f"  Net Success: {net_success:+d}" if net_success != 0 else "  Net Success: 0")
              
              net_advantage = result.advantage
              print(f"  Net Advantage: {net_advantage:+d}" if net_advantage != 0 else "  Net Advantage: 0")
              
              if result.triumph > 0:
                  print(f"  Triumph: {result.triumph}")
              
              if result.despair > 0:
                  print(f"  Despair: {result.despair}")
              
              if result.light > 0:
                  print(f"  Light Side: {result.light}")
              
              if result.dark > 0:
                  print(f"  Dark Side: {result.dark}")
              
              pool = result.dice_pool
              if pool:
                  print("\nDice Pool:")
                  if pool.boost > 0: print(f"  Boost: {pool.boost}")
                  if pool.ability > 0: print(f"  Ability: {pool.ability}")
                  if pool.proficiency > 0: print(f"  Proficiency: {pool.proficiency}")
                  if pool.setback > 0: print(f"  Setback: {pool.setback}")
                  if pool.difficulty > 0: print(f"  Difficulty: {pool.difficulty}")
                  if pool.challenge > 0: print(f"  Challenge: {pool.challenge}")
                  if pool.force > 0: print(f"  Force: {pool.force}")
              
              print("=========================================\n")
          
          def interactive_roll(self):
              if not HAS_RICH:
                  return self._interactive_roll_plain()
                  
              pool = DicePool()
              
              # Check if we want to load a preset
              use_preset = Confirm.ask("Do you want to use a saved preset?")
              if use_preset and self.roller.presets:
                  preset_names = list(self.roller.presets.keys())
                  preset_list = "\n".join([f"{i+1}. {name}" for i, name in enumerate(preset_names)])
                  self.console.print(f"Available presets:\n{preset_list}")
                  choice = Prompt.ask("Select preset (number or name)", default="1")
                  
                  try:
                      if choice.isdigit() and 1 <= int(choice) <= len(preset_names):
                          selected = preset_names[int(choice) - 1]
                      elif choice in preset_names:
                          selected = choice
                      else:
                          self.console.print("[red]Invalid preset, creating empty pool[/]")
                          selected = None
                      
                      if selected:
                          pool = self.roller.presets[selected]
                  except (ValueError, IndexError):
                      self.console.print("[red]Invalid selection, creating empty pool[/]")
              
              # Add dice
              while True:
                  self.console.print(Panel(Text(
                      f"Current Pool: "
                      f"[bright_blue]Boost: {pool.boost}[/] | "
                      f"[green]Ability: {pool.ability}[/] | "
                      f"[yellow]Proficiency: {pool.proficiency}[/] | "
                      f"[bright_black]Setback: {pool.setback}[/] | "
                      f"[purple]Difficulty: {pool.difficulty}[/] | "
                      f"[red]Challenge: {pool.challenge}[/] | "
                      f"[white]Force: {pool.force}[/]",
                      justify="center"
                  )))
                  
                  choice = Prompt.ask(
                      "Add or remove dice (b+/b-: boost, a+/a-: ability, p+/p-: proficiency, "
                      "s+/s-: setback, d+/d-: difficulty, c+/c-: challenge, f+/f-: force, "
                      "done: finish, clear: reset)",
                      default="done"
                  )
                  
                  if choice.lower() == "done":
                      break
                  elif choice.lower() == "clear":
                      pool = DicePool()
                      continue
                  
                  if len(choice) < 2:
                      self.console.print("[red]Invalid input[/]")
                      continue
                      
                  die_code = choice[0].lower()
                  operation = choice[1]
                  
                  count = 1
                  if len(choice) > 2 and choice[2:].isdigit():
                      count = int(choice[2:])
                  
                  if die_code == "b" and operation == "+":
                      pool.boost += count
                  elif die_code == "b" and operation == "-":
                      pool.boost = max(0, pool.boost - count)
                  elif die_code == "a" and operation == "+":
                      pool.ability += count
                  elif die_code == "a" and operation == "-":
                      pool.ability = max(0, pool.ability - count)
                  elif die_code == "p" and operation == "+":
                      pool.proficiency += count
                  elif die_code == "p" and operation == "-":
                      pool.proficiency = max(0, pool.proficiency - count)
                  elif die_code == "s" and operation == "+":
                      pool.setback += count
                  elif die_code == "s" and operation == "-":
                      pool.setback = max(0, pool.setback - count)
                  elif die_code == "d" and operation == "+":
                      pool.difficulty += count
                  elif die_code == "d" and operation == "-":
                      pool.difficulty = max(0, pool.difficulty - count)
                  elif die_code == "c" and operation == "+":
                      pool.challenge += count
                  elif die_code == "c" and operation == "-":
                      pool.challenge = max(0, pool.challenge - count)
                  elif die_code == "f" and operation == "+":
                      pool.force += count
                  elif die_code == "f" and operation == "-":
                      pool.force = max(0, pool.force - count)
                  else:
                      self.console.print("[red]Invalid input[/]")
              
              # Save as preset?
              if not pool.is_empty():
                  save_as_preset = Confirm.ask("Save this dice pool as a preset?")
                  if save_as_preset:
                      preset_name = Prompt.ask("Enter preset name")
                      if preset_name:
                          self.roller.presets[preset_name] = pool
                          self.roller.save_presets()
                          self.console.print(f"[green]Saved preset '{preset_name}'[/]")
              
              # Get roll description
              description = Prompt.ask("Enter roll description (optional)", default="")
              
              # Roll the dice
              result = self.roller.roll_dice_pool(pool, description)
              self.display_result(result)
              
              return result
          
          def _interactive_roll_plain(self):
              pool = DicePool()
              
              # Check if we want to load a preset
              print("Do you want to use a saved preset? (y/n)")
              use_preset = input().lower() == 'y'
              
              if use_preset and self.roller.presets:
                  preset_names = list(self.roller.presets.keys())
                  for i, name in enumerate(preset_names):
                      print(f"{i+1}. {name}")
                  
                  print("Select preset (number or name):")
                  choice = input()
                  
                  try:
                      if choice.isdigit() and 1 <= int(choice) <= len(preset_names):
                          selected = preset_names[int(choice) - 1]
                      elif choice in preset_names:
                          selected = choice
                      else:
                          print("Invalid preset, creating empty pool")
                          selected = None
                      
                      if selected:
                          pool = self.roller.presets[selected]
                  except (ValueError, IndexError):
                      print("Invalid selection, creating empty pool")
              
              # Add dice
              while True:
                  print("\nCurrent Pool:")
                  print(f"  Boost: {pool.boost}")
                  print(f"  Ability: {pool.ability}")
                  print(f"  Proficiency: {pool.proficiency}")
                  print(f"  Setback: {pool.setback}")
                  print(f"  Difficulty: {pool.difficulty}")
                  print(f"  Challenge: {pool.challenge}")
                  print(f"  Force: {pool.force}")
                  
                  print("\nAdd or remove dice (b+/b-: boost, a+/a-: ability, p+/p-: proficiency, " +
                        "s+/s-: setback, d+/d-: difficulty, c+/c-: challenge, f+/f-: force, " +
                        "done: finish, clear: reset):")
                  choice = input()
                  
                  if choice.lower() == "done":
                      break
                  elif choice.lower() == "clear":
                      pool = DicePool()
                      continue
                  
                  if len(choice) < 2:
                      print("Invalid input")
                      continue
                      
                  die_code = choice[0].lower()
                  operation = choice[1]
                  
                  count = 1
                  if len(choice) > 2 and choice[2:].isdigit():
                      count = int(choice[2:])
                  
                  if die_code == "b" and operation == "+":
                      pool.boost += count
                  elif die_code == "b" and operation == "-":
                      pool.boost = max(0, pool.boost - count)
                  elif die_code == "a" and operation == "+":
                      pool.ability += count
                  elif die_code == "a" and operation == "-":
                      pool.ability = max(0, pool.ability - count)
                  elif die_code == "p" and operation == "+":
                      pool.proficiency += count
                  elif die_code == "p" and operation == "-":
                      pool.proficiency = max(0, pool.proficiency - count)
                  elif die_code == "s" and operation == "+":
                      pool.setback += count
                  elif die_code == "s" and operation == "-":
                      pool.setback = max(0, pool.setback - count)
                  elif die_code == "d" and operation == "+":
                      pool.difficulty += count
                  elif die_code == "d" and operation == "-":
                      pool.difficulty = max(0, pool.difficulty - count)
                  elif die_code == "c" and operation == "+":
                      pool.challenge += count
                  elif die_code == "c" and operation == "-":
                      pool.challenge = max(0, pool.challenge - count)
                  elif die_code == "f" and operation == "+":
                      pool.force += count
                  elif die_code == "f" and operation == "-":
                      pool.force = max(0, pool.force - count)
                  else:
                      print("Invalid input")
              
              # Save as preset?
              if not pool.is_empty():
                  print("Save this dice pool as a preset? (y/n)")
                  save_as_preset = input().lower() == 'y'
                  if save_as_preset:
                      print("Enter preset name:")
                      preset_name = input()
                      if preset_name:
                          self.roller.presets[preset_name] = pool
                          self.roller.save_presets()
                          print(f"Saved preset '{preset_name}'")
              
              # Get roll description
              print("Enter roll description (optional):")
              description = input()
              
              # Roll the dice
              result = self.roller.roll_dice_pool(pool, description)
              self._display_result_plain(result)
              
              return result
          
          def view_history(self, limit: int = 10):
              if not self.roller.history:
                  if HAS_RICH:
                      self.console.print("[yellow]No roll history available[/]")
                  else:
                      print("No roll history available")
                  return
              
              history = list(reversed(self.roller.history))[:limit]
              
              if not HAS_RICH:
                  print(f"\n===== Last {len(history)} Rolls =====")
                  for i, result in enumerate(history):
                      print(f"\nRoll #{i+1} - {time.ctime(result.timestamp)}")
                      if result.description:
                          print(f"Description: {result.description}")
                      
                      print(f"Success/Failure: {result.success:+d}")
                      print(f"Advantage/Threat: {result.advantage:+d}")
                      
                      if result.triumph > 0:
                          print(f"Triumph: {result.triumph}")
                      if result.despair > 0:
                          print(f"Despair: {result.despair}")
                      if result.light > 0:
                          print(f"Light Side: {result.light}")
                      if result.dark > 0:
                          print(f"Dark Side: {result.dark}")
                  return
              
              table = Table(title=f"Last {len(history)} Rolls")
              table.add_column("#", style="cyan")
              table.add_column("Time", style="green")
              table.add_column("Description", style="blue")
              table.add_column("Success", style="yellow")
              table.add_column("Advantage", style="magenta")
              table.add_column("Triumph", style="bright_yellow")
              table.add_column("Despair", style="red")
              table.add_column("Force", style="bright_white")
              
              for i, result in enumerate(history):
                  time_str = time.strftime("%H:%M:%S", time.localtime(result.timestamp))
                  desc = result.description if result.description else "-"
                  success = f"{result.success:+d}" if result.success != 0 else "0"
                  advantage = f"{result.advantage:+d}" if result.advantage != 0 else "0"
                  triumph = str(result.triumph) if result.triumph > 0 else "-"
                  despair = str(result.despair) if result.despair > 0 else "-"
                  
                  force = ""
                  if result.light > 0 or result.dark > 0:
                      force = f"L:{result.light} D:{result.dark}"
                  else:
                      force = "-"
                  
                  table.add_row(
                      str(i+1), time_str, desc, success, advantage, 
                      triumph, despair, force
                  )
              
              self.console.print(table)
          
          def view_presets(self):
              if not self.roller.presets:
                  if HAS_RICH:
                      self.console.print("[yellow]No presets available[/]")
                  else:
                      print("No presets available")
                  return
              
              if not HAS_RICH:
                  print("\n===== Saved Presets =====")
                  for name, pool in self.roller.presets.items():
                      print(f"\n{name}:")
                      if pool.boost > 0: print(f"  Boost: {pool.boost}")
                      if pool.ability > 0: print(f"  Ability: {pool.ability}")
                      if pool.proficiency > 0: print(f"  Proficiency: {pool.proficiency}")
                      if pool.setback > 0: print(f"  Setback: {pool.setback}")
                      if pool.difficulty > 0: print(f"  Difficulty: {pool.difficulty}")
                      if pool.challenge > 0: print(f"  Challenge: {pool.challenge}")
                      if pool.force > 0: print(f"  Force: {pool.force}")
                  return
              
              table = Table(title="Saved Presets")
              table.add_column("Name", style="cyan")
              table.add_column("Boost", style="bright_blue")
              table.add_column("Ability", style="green")
              table.add_column("Proficiency", style="yellow")
              table.add_column("Setback", style="bright_black")
              table.add_column("Difficulty", style="purple")
              table.add_column("Challenge", style="red")
              table.add_column("Force", style="bright_white")
              
              for name, pool in self.roller.presets.items():
                  table.add_row(
                      name,
                      str(pool.boost) if pool.boost > 0 else "-",
                      str(pool.ability) if pool.ability > 0 else "-",
                      str(pool.proficiency) if pool.proficiency > 0 else "-",
                      str(pool.setback) if pool.setback > 0 else "-",
                      str(pool.difficulty) if pool.difficulty > 0 else "-",
                      str(pool.challenge) if pool.challenge > 0 else "-",
                      str(pool.force) if pool.force > 0 else "-"
                  )
              
              self.console.print(table)
          
          def parse_command_line(self, args):
              parser = argparse.ArgumentParser(description="Star Wars Narrative Dice System")
              subparsers = parser.add_subparsers(dest="command", help="Command")
              
              # Roll command
              roll_parser = subparsers.add_parser("roll", help="Roll dice")
              roll_parser.add_argument("-b", "--boost", type=int, default=0, help="Number of boost dice")
              roll_parser.add_argument("-a", "--ability", type=int, default=0, help="Number of ability dice")
              roll_parser.add_argument("-p", "--proficiency", type=int, default=0, help="Number of proficiency dice")
              roll_parser.add_argument("-s", "--setback", type=int, default=0, help="Number of setback dice")
              roll_parser.add_argument("-d", "--difficulty", type=int, default=0, help="Number of difficulty dice")
              roll_parser.add_argument("-c", "--challenge", type=int, default=0, help="Number of challenge dice")
              roll_parser.add_argument("-f", "--force", type=int, default=0, help="Number of force dice")
              roll_parser.add_argument("-i", "--interactive", action="store_true", help="Interactive mode")
              roll_parser.add_argument("--description", type=str, default="", help="Roll description")
              roll_parser.add_argument("--preset", type=str, help="Use a saved preset")
              
              # History command
              history_parser = subparsers.add_parser("history", help="View roll history")
              history_parser.add_argument("-n", "--number", type=int, default=10, help="Number of rolls to show")
              
              # Preset command
              preset_parser = subparsers.add_parser("preset", help="Manage presets")
              preset_parser.add_argument("action", choices=["list", "save", "delete"], help="Action to perform")
              preset_parser.add_argument("--name", type=str, help="Preset name")
              preset_parser.add_argument("-b", "--boost", type=int, default=0, help="Number of boost dice")
              preset_parser.add_argument("-a", "--ability", type=int, default=0, help="Number of ability dice")
              preset_parser.add_argument("-p", "--proficiency", type=int, default=0, help="Number of proficiency dice")
              preset_parser.add_argument("-s", "--setback", type=int, default=0, help="Number of setback dice")
              preset_parser.add_argument("-d", "--difficulty", type=int, default=0, help="Number of difficulty dice")
              preset_parser.add_argument("-c", "--challenge", type=int, default=0, help="Number of challenge dice")
              preset_parser.add_argument("-f", "--force", type=int, default=0, help="Number of force dice")
              
              # Interactive mode
              interactive_parser = subparsers.add_parser("interactive", help="Interactive mode")
              
              parsed_args = parser.parse_args(args)
              
              if not parsed_args.command:
                  # Default to interactive mode if no command specified
                  parsed_args.command = "interactive"
              
              return parsed_args
          
          def run_command(self, args):
              parsed_args = self.parse_command_line(args)
              
              if parsed_args.command == "roll":
                  if parsed_args.interactive:
                      self.interactive_roll()
                  else:
                      pool = DicePool()
                      
                      if parsed_args.preset and parsed_args.preset in self.roller.presets:
                          pool = self.roller.presets[parsed_args.preset]
                      else:
                          pool.boost = parsed_args.boost
                          pool.ability = parsed_args.ability
                          pool.proficiency = parsed_args.proficiency
                          pool.setback = parsed_args.setback
                          pool.difficulty = parsed_args.difficulty
                          pool.challenge = parsed_args.challenge
                          pool.force = parsed_args.force
                      
                      result = self.roller.roll_dice_pool(pool, parsed_args.description)
                      self.display_result(result)
              
              elif parsed_args.command == "history":
                  self.view_history(parsed_args.number)
              
              elif parsed_args.command == "preset":
                  if parsed_args.action == "list":
                      self.view_presets()
                  
                  elif parsed_args.action == "save":
                      if not parsed_args.name:
                          if HAS_RICH:
                              self.console.print("[red]Error: Preset name required[/]")
                          else:
                              print("Error: Preset name required")
                          return
                      
                      pool = DicePool(
                          boost=parsed_args.boost,
                          ability=parsed_args.ability,
                          proficiency=parsed_args.proficiency,
                          setback=parsed_args.setback,
                          difficulty=parsed_args.difficulty,
                          challenge=parsed_args.challenge,
                          force=parsed_args.force
                      )
                      
                      self.roller.presets[parsed_args.name] = pool
                      self.roller.save_presets()
                      
                      if HAS_RICH:
                          self.console.print(f"[green]Saved preset '{parsed_args.name}'[/]")
                      else:
                          print(f"Saved preset '{parsed_args.name}'")
                  
                  elif parsed_args.action == "delete":
                      if not parsed_args.name:
                          if HAS_RICH:
                              self.console.print("[red]Error: Preset name required[/]")
                          else:
                              print("Error: Preset name required")
                          return
                      
                      if parsed_args.name in self.roller.presets:
                          del self.roller.presets[parsed_args.name]
                          self.roller.save_presets()
                          
                          if HAS_RICH:
                              self.console.print(f"[green]Deleted preset '{parsed_args.name}'[/]")
                          else:
                              print(f"Deleted preset '{parsed_args.name}'")
                      else:
                          if HAS_RICH:
                              self.console.print(f"[red]Preset '{parsed_args.name}' not found[/]")
                          else:
                              print(f"Preset '{parsed_args.name}' not found")
              
              elif parsed_args.command == "interactive":
                  self.interactive_session()
          
          def interactive_session(self):
              if not HAS_RICH:
                  self._interactive_session_plain()
                  return
              
              self.console.print(Panel(
                  Text("Star Wars Narrative Dice System", justify="center"),
                  style="bold white on blue"
              ))
              
              while True:
                  choice = Prompt.ask(
                      "Choose an option",
                      choices=["roll", "history", "presets", "help", "quit"],
                      default="roll"
                  )
                  
                  if choice == "roll":
                      self.interactive_roll()
                  elif choice == "history":
                      count = Prompt.ask("Number of rolls to show", default="10")
                      try:
                          self.view_history(int(count))
                      except ValueError:
                          self.console.print("[red]Invalid number, showing 10 rolls[/]")
                          self.view_history(10)
                  elif choice == "presets":
                      self.view_presets()
                  elif choice == "help":
                      help_text = """
                      [bold]Star Wars Narrative Dice System Help[/bold]
                      
                      [bold]Dice Types:[/bold]
                      - [bright_blue]Boost (Blue d6)[/]: Adds minor benefits
                      - [green]Ability (Green d8)[/]: Basic positive dice
                      - [yellow]Proficiency (Yellow d12)[/]: Advanced positive dice, can roll Triumph
                      - [bright_black]Setback (Black d6)[/]: Minor negative dice
                      - [purple]Difficulty (Purple d8)[/]: Basic negative dice
                      - [red]Challenge (Red d12)[/]: Advanced negative dice, can roll Despair
                      - [white]Force (White d12)[/]: Light and Dark side force points
                      
                      [bold]Symbols:[/bold]
                      - Success (✓): Positive result
                      - Failure (✗): Negative result, cancels Success
                      - Advantage (a): Minor positive effect
                      - Threat (t): Minor negative effect, cancels Advantage
                      - Triumph (⚜): Major success, also counts as a Success
                      - Despair (⚠): Major failure, also counts as a Failure
                      - Light Side (○): Light Side Force points
                      - Dark Side (●): Dark Side Force points
                      
                      [bold]Commands:[/bold]
                      - roll: Roll dice
                      - history: View roll history
                      - presets: View and manage saved dice pools
                      - help: Show this help
                      - quit: Exit the application
                      """
                      self.console.print(Panel(Text(help_text, justify="left")))
                  elif choice == "quit":
                      self.console.print("[green]Exiting Star Wars Dice Roller. May the Force be with you![/]")
                      break
          
          def _interactive_session_plain(self):
              print("\n===== Star Wars Narrative Dice System =====\n")
              
              while True:
                  print("\nChoose an option:")
                  print("1. Roll dice")
                  print("2. View history")
                  print("3. View presets")
                  print("4. Help")
                  print("5. Quit")
                  
                  choice = input("\nEnter option (1-5): ")
                  
                  if choice == "1":
                      self._interactive_roll_plain()
                  elif choice == "2":
                      count_input = input("Number of rolls to show (default 10): ")
                      try:
                          count = int(count_input) if count_input.strip() else 10
                          self.view_history(count)
                      except ValueError:
                          print("Invalid number, showing 10 rolls")
                          self.view_history(10)
                  elif choice == "3":
                      self.view_presets()
                  elif choice == "4":
                      print("\n===== Star Wars Narrative Dice System Help =====")
                      print("\nDice Types:")
                      print("- Boost (Blue d6): Adds minor benefits")
                      print("- Ability (Green d8): Basic positive dice")
                      print("- Proficiency (Yellow d12): Advanced positive dice, can roll Triumph")
                      print("- Setback (Black d6): Minor negative dice")
                      print("- Difficulty (Purple d8): Basic negative dice")
                      print("- Challenge (Red d12): Advanced negative dice, can roll Despair")
                      print("- Force (White d12): Light and Dark side force points")
                      
                      print("\nSymbols:")
                      print("- Success (✓): Positive result")
                      print("- Failure (✗): Negative result, cancels Success")
                      print("- Advantage (a): Minor positive effect")
                      print("- Threat (t): Minor negative effect, cancels Advantage")
                      print("- Triumph (⚜): Major success, also counts as a Success")
                      print("- Despair (⚠): Major failure, also counts as a Failure")
                      print("- Light Side (○): Light Side Force points")
                      print("- Dark Side (●): Dark Side Force points")
                  elif choice == "5":
                      print("\nExiting Star Wars Dice Roller. May the Force be with you!")
                      break
                  else:
                      print("Invalid option, please try again")
      
      def main():
          ui = DiceUI()
          args = sys.argv[1:]
          
          if len(args) == 0:
              ui.interactive_session()
          else:
              ui.run_command(args)
      
      if __name__ == "__main__":
          main()
    '';
    
    # Install required dependencies
    propagatedBuildInputs = with pkgs.python3Packages; [
      rich
    ];

    # Don't run tests
    doCheck = false;
  };
  
  # Generate the shell wrapper script
  swdice-wrapper = pkgs.writeScriptBin "swdice" ''
    #!/bin/sh
    exec ${swdice-app}/bin/swdice "$@"
  '';

in {
  options.programs.swdice = {
    enable = mkEnableOption "Star Wars Narrative Dice System roller";
    
    package = mkOption {
      type = types.package;
      default = swdice-app;
      description = "The Star Wars dice roller package to use.";
    };
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = [
      swdice-wrapper
      (pkgs.writeTextFile {
        name = "swdice-man";
        destination = "/share/man/man1/swdice.1";
        text = ''
          .TH SWDICE 1 "February 2025" "Star Wars Dice Roller Manual"
          .SH NAME
          swdice \- Star Wars Narrative Dice System roller
          
          .SH SYNOPSIS
          .B swdice
          [COMMAND] [OPTIONS]
          
          .SH DESCRIPTION
          Roll dice for the Star Wars tabletop RPG Narrative Dice System.
          
          .SH COMMANDS
          .TP
          .B roll
          Roll a set of dice
          .TP
          .B history
          View roll history
          .TP
          .B preset
          Manage dice pool presets
          .TP
          .B interactive
          Start interactive session (default if no command specified)
          
          .SH OPTIONS
          .SS Roll Command Options
          .TP
          .B \-b, \-\-boost NUMBER
          Number of boost dice (blue d6)
          .TP
          .B \-a, \-\-ability NUMBER
          Number of ability dice (green d8)
          .TP
          .B \-p, \-\-proficiency NUMBER
          Number of proficiency dice (yellow d12)
          .TP
          .B \-s, \-\-setback NUMBER
          Number of setback dice (black d6)
          .TP
          .B \-d, \-\-difficulty NUMBER
          Number of difficulty dice (purple d8)
          .TP
          .B \-c, \-\-challenge NUMBER
          Number of challenge dice (red d12)
          .TP
          .B \-f, \-\-force NUMBER
          Number of force dice (white d12)
          .TP
          .B \-i, \-\-interactive
          Use interactive mode to build dice pool
          .TP
          .B \-\-description TEXT
          Add a description to the roll
          .TP
          .B \-\-preset NAME
          Use a saved dice pool preset
          
          .SS History Command Options
          .TP
          .B \-n, \-\-number NUMBER
          Number of historical rolls to show (default: 10)
          
          .SS Preset Command Options
          .TP
          .B list
          List all saved presets
          .TP
          .B save
          Save a new preset
          .TP
          .B delete
          Delete an existing preset
          .TP
          .B \-\-name NAME
          Preset name (required for save and delete)
          
          .SH EXAMPLES
          .TP
          .B swdice
          Start interactive session
          .TP
          .B swdice roll \-a 2 \-p 1 \-d 2
          Roll 2 ability dice, 1 proficiency die, and 2 difficulty dice
          .TP
          .B swdice roll \-\-preset "Piloting"
          Roll using the saved "Piloting" preset
          .TP
          .B swdice preset list
          List all saved presets
          .TP
          .B swdice history \-n 5
          Show the last 5 rolls
          
          .SH FILES
          .TP
          .I ~/.config/swdice/history.json
          Roll history storage
          .TP
          .I ~/.config/swdice/presets.json
          Saved dice pool presets
          
          .SH AUTHOR
          Created as a NixOS module for Star Wars tabletop RPG players.
        '';
      })
    ];
    
    # Install a desktop entry for the application
    environment.sessionVariables = {
      XDG_DATA_DIRS = [
        "${pkgs.writeTextDir "share/applications/swdice.desktop" ''
          [Desktop Entry]
          Type=Application
          Name=Star Wars Dice Roller
          Comment=Roll dice for the Star Wars Narrative Dice System
          Exec=swdice
          Icon=applications-games
          Terminal=true
          Categories=Game;RolePlaying;
        ''}/share"
      ];
    };
    
    # Add shell completion
    programs.bash.shellAliases = {
      "swdice-roll" = "swdice roll";
      "swdice-interactive" = "swdice interactive";
    };
    
    programs.bash.shellInit = ''
      _swdice_completions() {
        local cur prev opts
        COMPREPLY=()
        cur="''${COMP_WORDS[COMP_CWORD]}"
        prev="''${COMP_WORDS[COMP_CWORD-1]}"
        
        case "''${prev}" in
          swdice)
            opts="roll history preset interactive"
            COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            return 0
            ;;
          roll)
            opts="-b --boost -a --ability -p --proficiency -s --setback -d --difficulty -c --challenge -f --force -i --interactive --description --preset"
            COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            return 0
            ;;
          preset)
            opts="list save delete"
            COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            return 0
            ;;
          history)
            opts="-n --number"
            COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            return 0
            ;;
        esac
        
        # Handle flags
        case "''${cur}" in
          -*)
            if [[ "''${COMP_WORDS[@]}" =~ "roll" ]]; then
              opts="-b --boost -a --ability -p --proficiency -s --setback -d --difficulty -c --challenge -f --force -i --interactive --description --preset"
              COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            elif [[ "''${COMP_WORDS[@]}" =~ "preset" ]]; then
              opts="--name -b --boost -a --ability -p --proficiency -s --setback -d --difficulty -c --challenge -f --force"
              COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            elif [[ "''${COMP_WORDS[@]}" =~ "history" ]]; then
              opts="-n --number"
              COMPREPLY=( $(compgen -W "''${opts}" -- "''${cur}") )
            fi
            return 0
            ;;
        esac
        
        return 0
      }
      
      complete -F _swdice_completions swdice
    '';
  };
}

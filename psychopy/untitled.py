from psychopy import visual, event, gui, data
import random
import pandas as pd

#define dialogue prompt
dialog = gui.Dlg(title = "Slot machine experiment")
dialog.addField("Participant ID:")
dialog.addField("Age:")
dialog.addField("Gender:", choices = ["female", "male", "other"])
dialog.show()

if dialog.OK:
    ID = dialog.data["Participant ID:"]
    Age = dialog.data["Age:"]
    Gender = dialog.data["Gender:"]
elif dialog.Cancel:
    core.quit()
    
#define window
win = visual.Window(fullscr = True, color='black')

#get date for unique logfile name
date = data.getDateStr()

#define log file
columns = ["timestamp", "ID", "age", "gender", "condition", "trial", "choice", "reward", "cum_reward"]

#define an empty data frame
DATA = pd.DataFrame(columns = columns)

#Make a function that shows text
def msg(txt):
    message = visual.TextStim(win, text = txt, units='pix', height=30)
    message.draw()
    win.flip()
    event.waitKeys(keyList = "space")
    
instruction = '''
Welcome to the Slot Machine experiment! \n\n
You will be gambling. Make sure to get as high a score as possible! \n\n
There are 2 machines you can play. There will be two sessions. In each session, you will get to play 100 rounds. \n\n
If you want to pull the machine on the left, press 'left'. \n\n
If you want to pull the machine on the right, press 'right'. \n\n
After you've seen your rewards/losses, continue with "space". \n\n
Press the "space"-button when you are ready to start.'''

intermediary = '''
You are now beginning a different session. These are NEW slot machines!!!'''

goodbye = '''
The experiment is now done. Thank you for your participation.'''

condition = ["gain", "loss"]
random.shuffle(condition)

img = "image.png"
img = visual.ImageStim(win, image = img)
loop_counter = 0

msg(instruction)

for i in condition:
    
    loop_counter += 1
    score = 0
    condition = i
    
    for j in range(0, 100): 
        
        trial = j
        
        img.draw()
        win.flip()
        
        key = event.waitKeys(keyList = ["left", "right"])
        
        if key == ["left"] and i == "gain": 
            
            outcomes = [4, 0]
            probabilities = [1/4, 3/4]
            
            reward = random.choices(outcomes, probabilities)[0]
        
        if key == ["right"] and i == "gain": 
            
            outcomes = [1, 0]
            probabilities = [3/4, 1/4]
                        
            reward = random.choices(outcomes, probabilities)[0]
            
        if key == ["left"] and i == "loss": 
            
            outcomes = [-1, -0]
            probabilities = [3/4, 1/4]
            
            reward = random.choices(outcomes, probabilities)[0]
            
        if key == ["right"] and i == "loss": 
            
            outcomes = [-4, -0]
            probabilities = [1/4, 3/4]
            
            reward = random.choices(outcomes, probabilities)[0]
            
        
        score += reward
        
        new = {
        "timestamp": date,
        "ID": ID,
        "age": Age,
        "gender": Gender,
        "condition": i,
        "trial": j,
        "choice": key,
        "reward": reward,
        "cum_reward": score}
        
        temp = pd.DataFrame(new)
        DATA = pd.concat([DATA, temp], ignore_index=True)
        
        feedback = f'''
        Reward: {reward}. Total score: {score}.'''
        msg(feedback)
        
    if loop_counter == 1: 
        msg(intermediary)
        
    
#make file name
logfilename = "logfile_{}_{}.csv".format(ID, date)
#save the logfile to the hard drive
DATA.to_csv(logfilename)

msg(goodbye)










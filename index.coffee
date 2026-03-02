command: ""
refreshFrequency: false

render: -> """
<div class="container">

  <div class="dateBox">
    <div id="dayName"></div>
    <div id="dayNumber"></div>
    <div id="monthName"></div>
  </div>

  <form>
    <input type="text" id="newTask" placeholder="Add a task...">
    <button id="addBtn">Add</button>
  </form>

  <div class="progressBar">
    <div class="progressFill"></div>
  </div>
  <div id="progressLabel">0 / 0 tasks done</div>

  <div id="taskList"></div>

  <div class="listView">
    <h3>My Tasks</h3>
    <ul id="plainList"></ul>
  </div>

</div>
"""

style: """
:root{
  --darkGreen:#1b4332;
  --mediumGreen:#2d6a4f;
  --lightGreen:#74c69d;
  --softGreen:#d8f3dc;
  --bgGreen:#f1fdf6;
  --white:#ffffff;
}

*{ box-sizing:border-box; }

body{
  margin:0;
  font-family:"Segoe UI", sans-serif;
}

.container{
  position:absolute;
  top:60px;
  right:40px;

  width:520px;
  background:var(--white);
  padding:25px;
  border-radius:18px;
  box-shadow:0 15px 30px rgba(0,0,0,0.08);
}

/* Date Header */
.dateBox{
  background:var(--softGreen);
  padding:15px;
  border-radius:15px;
  margin-bottom:20px;
}
#dayName{ font-weight:600; color:var(--mediumGreen); }
#dayNumber{ font-size:34px; font-weight:800; color:var(--darkGreen); }
#monthName{ font-weight:500; color:var(--mediumGreen); }

/* Input */
form{ display:flex; gap:10px; }
#newTask{
  flex:1;
  padding:12px;
  border-radius:12px;
  border:2px solid var(--softGreen);
  outline:none;
}
#newTask:focus{ border-color:var(--lightGreen); }

#addBtn{
  padding:12px 16px;
  border:none;
  border-radius:12px;
  background:var(--mediumGreen);
  color:white;
  font-weight:800;
  cursor:pointer;
}
#addBtn:hover{ background:var(--darkGreen); }

/* Progress */
.progressBar{
  margin-top:20px;
  background:#e6e6e6;
  border-radius:20px;
  height:12px;
  overflow:hidden;
}
.progressFill{
  height:100%;
  width:0%;
  background:linear-gradient(to right, var(--lightGreen), var(--mediumGreen));
  transition:width 0.25s ease;
}
#progressLabel{
  text-align:center;
  margin-top:8px;
  font-weight:700;
  color:var(--mediumGreen);
}

/* Task Cards */
#taskList{
  margin-top:20px;
  display:flex;
  flex-direction:column;
  gap:10px;
}

.task{
  background:var(--softGreen);
  padding:12px;
  border-radius:14px;
  display:flex;
  align-items:center;
  gap:10px;
}

.task input[type="checkbox"]{ accent-color:var(--mediumGreen); }

.TaskText{
  flex:1;
  font-weight:650;
  color:var(--darkGreen);
}

.task.done .TaskText{
  opacity:0.6;
  text-decoration:line-through;
}

/* Delete button */
.deleteBtn{
  border:none;
  background:transparent;
  cursor:pointer;
  font-size:16px;
  font-weight:900;
  color:var(--darkGreen);
  padding:6px 10px;
  border-radius:10px;
}
.deleteBtn:hover{
  background:rgba(45,106,79,0.15);
}

/* List View */
.listView{
  margin-top:25px;
  background:var(--softGreen);
  padding:15px;
  border-radius:15px;
}

.listView h3{
  margin:0 0 10px;
  color:var(--darkGreen);
}

.listView ul{
  list-style:none;
  padding:0;
  margin:0;
  display:flex;
  flex-direction:column;
  gap:8px;
}

.listItem{
  display:flex;
  align-items:center;
  gap:10px;
  padding:10px 12px;
  border-radius:12px;
  background:rgba(255,255,255,0.55);
}

.listItem .text{
  flex:1;
  font-weight:650;
  color:var(--mediumGreen);
}

.listItem.done .text{
  text-decoration:line-through;
  opacity:0.6;
}

.miniTag{
  font-size:12px;
  font-weight:800;
  padding:4px 8px;
  border-radius:999px;
  background:rgba(45,106,79,0.12);
  color:var(--darkGreen);
  border:1px solid rgba(45,106,79,0.18);
}
"""

afterRender: (domEl) ->
  $ = (sel) -> domEl.querySelector(sel)

  today = new Date()
  $("#dayName").textContent = today.toLocaleDateString("en-US", { weekday: "long" })
  $("#dayNumber").textContent = today.getDate()
  $("#monthName").textContent = today.toLocaleDateString("en-US", { month: "long" })

  addBtn = $("#addBtn")
  newTask = $("#newTask")
  taskList = $("#taskList")
  plainList = $("#plainList")

  nextId = 1

  removeTaskById = (id) ->
    task = taskList.querySelector(".task[data-id='#{id}']")
    if task? then task.remove()
    updateProgress()

  rebuildList = ->
    plainList.innerHTML = ""
    tasks = taskList.querySelectorAll(".task")

    tasks.forEach (task) ->
      id = task.dataset.id
      text = task.querySelector(".TaskText").textContent
      checked = task.querySelector("input[type='checkbox']").checked

      li = document.createElement("li")
      li.className = "listItem"
      if checked then li.classList.add("done")
      li.dataset.id = id

      tag = document.createElement("span")
      tag.className = "miniTag"
      tag.textContent = if checked then "Done" else "To do"

      span = document.createElement("span")
      span.className = "text"
      span.textContent = text

      del = document.createElement("button")
      del.type = "button"
      del.className = "deleteBtn"
      del.textContent = "X"
      del.title = "Remove task"
      del.addEventListener "click", -> removeTaskById(id)

      li.appendChild(tag)
      li.appendChild(span)
      li.appendChild(del)
      plainList.appendChild(li)

  updateProgress = ->
    checkboxes = taskList.querySelectorAll("input[type='checkbox']")
    checked = Array.from(checkboxes).filter((cb) -> cb.checked).length
    total = checkboxes.length

    percent = if total is 0 then 0 else Math.round((checked / total) * 100)
    $(".progressFill").style.width = percent + "%"

    $("#progressLabel").textContent = "#{checked} / #{total} tasks done"

    taskList.querySelectorAll(".task").forEach (task) ->
      cb = task.querySelector("input[type='checkbox']")
      task.classList.toggle("done", cb.checked)

    rebuildList()

  addBtn.addEventListener "click", (e) ->
    e.preventDefault()
    text = newTask.value.trim()
    return unless text

    id = String(nextId)
    nextId += 1

    task = document.createElement("div")
    task.className = "task"
    task.dataset.id = id

    checkbox = document.createElement("input")
    checkbox.type = "checkbox"
    checkbox.addEventListener "change", updateProgress

    span = document.createElement("span")
    span.className = "TaskText"
    span.textContent = text

    deleteBtn = document.createElement("button")
    deleteBtn.type = "button"
    deleteBtn.className = "deleteBtn"
    deleteBtn.textContent = "X"
    deleteBtn.title = "Remove task"
    deleteBtn.addEventListener "click", -> removeTaskById(id)

    task.appendChild(checkbox)
    task.appendChild(span)
    task.appendChild(deleteBtn)

    taskList.appendChild(task)
    newTask.value = ""
    newTask.focus()
    updateProgress()

  newTask.addEventListener "keydown", (e) ->
    if e.key is "Enter" then addBtn.click()

  updateProgress()
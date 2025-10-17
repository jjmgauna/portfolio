import React, { useState, useEffect } from 'react';
import './App.css'; // Asumiendo que tienes un archivo CSS para estilos

// Función para obtener notas del LocalStorage
const getNotesFromStorage = () => {
  const storedNotes = localStorage.getItem('react-notes');
  return storedNotes ? JSON.parse(storedNotes) : [];
};

function App() {
  const [notes, setNotes] = useState(getNotesFromStorage);
  const [newNoteText, setNewNoteText] = useState('');

  // Sincroniza las notas con LocalStorage cada vez que 'notes' cambie
  useEffect(() => {
    localStorage.setItem('react-notes', JSON.stringify(notes));
  }, [notes]);

  // Manejador para agregar una nueva nota
  const addNote = (e) => {
    e.preventDefault();
    if (newNoteText.trim() === '') return;

    const newNote = {
      id: Date.now(),
      text: newNoteText,
    };
    
    setNotes([...notes, newNote]);
    setNewNoteText(''); // Limpiar el input
  };

  // Manejador para eliminar una nota
  const deleteNote = (id) => {
    setNotes(notes.filter(note => note.id !== id));
  };

  return (
    <div className="app">
      <h1>Notas con React y LocalStorage 📌</h1>

      {/* Formulario para agregar nota */}
      <form onSubmit={addNote} className="note-form">
        <input
          type="text"
          value={newNoteText}
          onChange={(e) => setNewNoteText(e.target.value)}
          placeholder="Escribe una nueva nota..."
        />
        <button type="submit">Agregar Nota</button>
      </form>
      
      {/* Lista de Notas */}
      <div className="notes-list">
        {notes.length === 0 ? (
          <p>No tienes notas. ¡Agrega una!</p>
        ) : (
          notes.map(note => (
            <div key={note.id} className="note-item">
              <p>{note.text}</p>
              <button onClick={() => deleteNote(note.id)}>Eliminar</button>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;
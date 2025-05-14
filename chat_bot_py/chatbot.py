import json
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB

class ChatBot:
    def __init__(self, memory_file="memory.json"):
        self.memory_file = memory_file
        self.vectorizer = CountVectorizer()
        self.model = MultinomialNB()
        self.load_memory()

    def load_memory(self):
        try:
            with open(self.memory_file, "r") as f:
                self.memory = json.load(f)
        except FileNotFoundError:
            self.memory = {"questions": [], "answers": []}

        if self.memory["questions"]:
            X = self.vectorizer.fit_transform(self.memory["questions"])
            y = self.memory["answers"]
            self.model.fit(X, y)

    def save_memory(self):
        with open(self.memory_file, "w") as f:
            json.dump(self.memory, f)

    def train(self, question, answer):
        self.memory["questions"].append(question)
        self.memory["answers"].append(answer)
        self.save_memory()
        X = self.vectorizer.fit_transform(self.memory["questions"])
        y = self.memory["answers"]
        self.model.fit(X, y)

    def get_response(self, user_input):
        if not self.memory["questions"]:
            return "Saya belum tahu jawabannya. Ajarin dong!"
        X = self.vectorizer.transform([user_input])
        return self.model.predict(X)[0]

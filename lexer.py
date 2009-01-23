#!/usr/bin/env python
import re

TOKEN_VALUE = 1.00

class Lexer(object):
    
    documents = {}
    tokens = {}

    def add_document(self, source):
        index = {}
        content = " ".join(file(source).readlines())
        
        # gay as fuck way of formatting for the lexer
        tokenlist = self.tokens_from(content)

        for token in tokenlist:
            if token in index.keys():
                index[token] += TOKEN_VALUE
            else:
                index[token] = TOKEN_VALUE
        
        self.documents[source] = index

    def index(self, document):
        if document not in self.documents.keys():
            self.add_document(document)

        self._index(document)
    
    def _index(self, document):
        for token in self.documents[document]:
            if token in self.tokens.keys():
                if document not in self.tokens[token]:
                    self.tokens[token].append(document)
            else:
                self.tokens[token] = [document]

    def tokens_from(self, content):
        tokens = []

        reg = re.compile('[^a-z ]')
        content = reg.sub('', content.lower())

        for token in content.split(" "):
            if token: tokens.append(token)

        return tokens

    def sort_tokens(self):
        self.sort_order = sorted(self.tokens.items(), lambda x, y:
                                 cmp(self.count_token(x[0]),
                                     self.count_token(y[0])), reverse=True)

    def count_token(self, token):
        count = 0
        for document in self.tokens[token]:
            count += self.documents[document][token]
        return count


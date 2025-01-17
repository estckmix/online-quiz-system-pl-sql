-- 1. Database Schema Design
-- Create a table to store users
CREATE TABLE users (
    user_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each user
    username VARCHAR2(50) NOT NULL, -- Username
    password VARCHAR2(50) NOT NULL, -- Password
    email VARCHAR2(100) UNIQUE NOT NULL -- Email address
);

-- Create a table to store quiz details
CREATE TABLE quizzes (
    quiz_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each quiz
    quiz_name VARCHAR2(100) NOT NULL -- Name of the quiz
);

-- Create a table to store questions
CREATE TABLE questions (
    question_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each question
    quiz_id NUMBER NOT NULL REFERENCES quizzes(quiz_id), -- Foreign key to quizzes
    question_text VARCHAR2(500) NOT NULL -- The question text
);

-- Create a table to store answers
CREATE TABLE answers (
    answer_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each answer
    question_id NUMBER NOT NULL REFERENCES questions(question_id), -- Foreign key to questions
    answer_text VARCHAR2(200) NOT NULL, -- The answer text
    is_correct CHAR(1) CHECK (is_correct IN ('Y', 'N')) -- Indicates if the answer is correct
);

-- Create a table to store user responses
CREATE TABLE user_responses (
    response_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each response
    user_id NUMBER NOT NULL REFERENCES users(user_id), -- Foreign key to users
    question_id NUMBER NOT NULL REFERENCES questions(question_id), -- Foreign key to questions
    selected_answer_id NUMBER NOT NULL REFERENCES answers(answer_id), -- User-selected answer
    is_correct CHAR(1) CHECK (is_correct IN ('Y', 'N')) -- Indicates if the user's answer was correct
);

-- Create a table to track user scores
CREATE TABLE scores (
    score_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, -- Unique ID for each score
    user_id NUMBER NOT NULL REFERENCES users(user_id), -- Foreign key to users
    quiz_id NUMBER NOT NULL REFERENCES quizzes(quiz_id), -- Foreign key to quizzes
    total_score NUMBER NOT NULL -- Total score for the quiz
);

-- 2. User Registration Procedure
CREATE OR REPLACE PROCEDURE register_user(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_email IN VARCHAR2
) IS
BEGIN
    INSERT INTO users (username, password, email)
    VALUES (p_username, p_password, p_email);
    COMMIT; -- Save the changes
END;
/

-- 3. Quiz Creation Procedure
CREATE OR REPLACE PROCEDURE create_quiz(
    p_quiz_name IN VARCHAR2
) IS
BEGIN
    INSERT INTO quizzes (quiz_name)
    VALUES (p_quiz_name);
    COMMIT; -- Save the changes
END;
/

-- 4. Add Question to Quiz Procedure
CREATE OR REPLACE PROCEDURE add_question(
    p_quiz_id IN NUMBER,
    p_question_text IN VARCHAR2
) IS
BEGIN
    INSERT INTO questions (quiz_id, question_text)
    VALUES (p_quiz_id, p_question_text);
    COMMIT; -- Save the changes
END;
/

-- 5. Add Answer to Question Procedure
CREATE OR REPLACE PROCEDURE add_answer(
    p_question_id IN NUMBER,
    p_answer_text IN VARCHAR2,
    p_is_correct IN CHAR
) IS
BEGIN
    INSERT INTO answers (question_id, answer_text, is_correct)
    VALUES (p_question_id, p_answer_text, p_is_correct);
    COMMIT; -- Save the changes
END;
/

-- 6. Record User Response Procedure
CREATE OR REPLACE PROCEDURE record_response(
    p_user_id IN NUMBER,
    p_question_id IN NUMBER,
    p_selected_answer_id IN NUMBER
) IS
    v_is_correct CHAR(1);
BEGIN
    -- Check if the selected answer is correct
    SELECT is_correct
    INTO v_is_correct
    FROM answers
    WHERE answer_id = p_selected_answer_id;

    -- Insert the response into the user_responses table
    INSERT INTO user_responses (user_id, question_id, selected_answer_id, is_correct)
    VALUES (p_user_id, p_question_id, p_selected_answer_id, v_is_correct);

    COMMIT; -- Save the changes
END;
/

-- 7. Calculate and Save User Score Procedure
CREATE OR REPLACE PROCEDURE calculate_score(
    p_user_id IN NUMBER,
    p_quiz_id IN NUMBER
) IS
    v_total_score NUMBER;
BEGIN
    -- Calculate the total score for the user on the given quiz
    SELECT COUNT(*)
    INTO v_total_score
    FROM user_responses ur
    JOIN questions q ON ur.question_id = q.question_id
    WHERE ur.user_id = p_user_id
      AND q.quiz_id = p_quiz_id
      AND ur.is_correct = 'Y';

    -- Insert the score into the scores table
    INSERT INTO scores (user_id, quiz_id, total_score)
    VALUES (p_user_id, p_quiz_id, v_total_score);

    COMMIT; -- Save the changes
END;
/

-- 8. Test the System
BEGIN
    -- Register a user
    register_user('test_user', 'password123', 'test_user@example.com');

    -- Create a quiz
    create_quiz('PL/SQL Basics Quiz');

    -- Add a question to the quiz
    add_question(1, 'What is the purpose of a PL/SQL block?');

    -- Add answers to the question
    add_answer(1, 'To execute SQL statements', 'N');
    add_answer(1, 'To group related statements', 'Y');
    add_answer(1, 'To store data permanently', 'N');
END;
/

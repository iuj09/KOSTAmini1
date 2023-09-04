ALTER TABLE MEETS ADD ENTER NUMBER DEFAULT '1';

ALTER TABLE MEETS DROP COLUMN ENTER;

CREATE TABLE MEMBER_MEETS_JOIN (
    MEMBERS_NO              NUMBER,
    MEETS_NO                NUMBER,

    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO),
    FOREIGN KEY(MEETS_NO) REFERENCES MEETS(NO)
);


-- 지역
CREATE TABLE LOCATIONS (
    -- 번호
    NO                  NUMBER                  PRIMARY KEY,
    -- 지역 이름
    NAME                VARCHAR2(100)           UNIQUE
);

-- 관심사
CREATE TABLE FAVORITES (
    -- 번호
    NO                  NUMBER                  PRIMARY KEY,
    -- 이름
    NAME                VARCHAR2(100)           NOT NULL,
    -- 관심이 등록되어 있는 회원 수
    HEART               NUMBER                  DEFAULT 0
);

-- 회원
CREATE TABLE MEMBERS (
    -- 번호
    NO                  NUMBER                  PRIMARY KEY,
    -- 아이디
    ID                  VARCHAR2(100)           UNIQUE,
    -- 비밀번호
    PWD                 VARCHAR2(100)           NOT NULL,
    -- 이름
    NAME                VARCHAR2(100)           NOT NULL,
    -- 이메일
    EMAIL               VARCHAR2(100)           NOT NULL,
    -- 가입 날짜
    JOIN_DATE           DATE                    DEFAULT SYSDATE,
    -- 슈퍼 계정 설정 여부(0: 일반계정 / 1: 슈퍼계정)
    ADMIN               CHAR(1)                 DEFAULT '0',                    
    
    -- FK
    -- 지역 번호
    LOCATIONS_NO         NUMBER                 NOT NULL,
    -- 관심사 번호
    FAVORITES_NO         NUMBER                 NOT NULL,
    
    -- 제약조건
    CONSTRAINT FK_LOCATIONS_NO FOREIGN KEY(LOCATIONS_NO) REFERENCES LOCATIONS(NO) ON DELETE SET NULL,
    CONSTRAINT FK_FAVORITES_NO FOREIGN KEY(FAVORITES_NO) REFERENCES FAVORITES(NO) ON DELETE SET NULL
);

-- 게시판
CREATE TABLE ARTICLES (
    -- 번호
    NO                  NUMBER                 PRIMARY KEY,
    -- 제목
    TITLE               VARCHAR2(100)          NOT NULL,
    -- 내용
    CONTENT             VARCHAR2(100)          NOT NULL,
    -- 좋아요 수
    HEART               NUMBER                 DEFAULT 0,
    -- 첫 게시 날짜
    W_DATE              DATE                   DEFAULT SYSDATE,
    -- 최종 수정 날짜
    E_DATE              DATE                   DEFAULT SYSDATE,

    -- FK
    -- 회원 번호
    MEMBERS_NO          NUMBER                 NOT NULL,
    -- 관심사 번호
    FAVORITES_NO        NUMBER                 NOT NULL,

    -- 제약조건  
    CONSTRAINT FK_MEMBERS_NO FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE,
    FOREIGN KEY(FAVORITES_NO) REFERENCES FAVORITES(NO) ON DELETE SET NULL
);

-- 댓글
CREATE TABLE REPLIES (
    -- 이름
    NO                  NUMBER                  PRIMARY KEY,
    -- 내용
    CONTENT             VARCHAR2(100)           NOT NULL,
    -- 첫 게시 날짜
    W_DATE              DATE                    DEFAULT SYSDATE,
    -- 최종 수정 날짜
    E_DATE              DATE                    DEFAULT SYSDATE,
    -- 좋아요 수
    HEART               NUMBER                  DEFAULT 0,

    -- FK
    -- 게시판 번호
    ARTICLES_NO         NUMBER                  NOT NULL,
    -- 회원 번호
    MEMBERS_NO          NUMBER                  NOT NULL,
    
    -- 제약조건
    CONSTRAINT FK_ARTICLES_NO FOREIGN KEY(ARTICLES_NO) REFERENCES ARTICLES(NO) ON DELETE CASCADE,
    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE
);

-- 모집글
CREATE TABLE MEETS (
    -- 번호
    NO                  NUMBER                  PRIMARY KEY,
    -- 모집인원 수
    RECURIT             NUMBER                  DEFAULT 1,
    -- 참가인원 수
    ENTER               NUMBER                  DEFAULT 1,
    -- 제목
    TITLE               VARCHAR2(100)           NOT NULL,
    -- 내용
    CONTENT             VARCHAR2(100)           NOT NULL,
    -- 첫 게시 날짜
    W_DATE              DATE                    DEFAULT SYSDATE,
    -- 마지막 수정 날짜
    E_DATE              DATE                    DEFAULT SYSDATE,
    -- 마감 날짜
    DEADLINE            DATE                    NOT NULL,

    -- FK
    -- 지역 번호
    LOCATIONS_NO         NUMBER                 NOT NULL,
    -- 회원 번호
    MEMBERS_NO           NUMBER                 NOT NULL,
    
    -- 제약조건
    FOREIGN KEY(LOCATIONS_NO) REFERENCES LOCATIONS(NO) ON DELETE SET NULL,
    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE
);

-- 게시판 댓글
CREATE TABLE MEETS_REPLIES (
    -- 번호
    NO                  NUMBER                  PRIMARY KEY,
    -- 내용
    CONTENT             VARCHAR2(100)           NOT NULL,
    -- 첫 게시 날짜
    W_DATE              DATE                    DEFAULT SYSDATE,
    -- 마지막 수정 날짜
    E_DATE              DATE                    DEFAULT SYSDATE,
    -- 대댓글 번호(이 번호는 MEETS_REPLIES의 NO)
    IN_REPLY            NUMBER                  DEFAULT 0,

    -- FK
    -- 모집글 번호
    MEETS_NO         NUMBER,
    -- 회원 번호
    MEMBERS_NO       NUMBER,
    
    -- 제약조건
    CONSTRAINT FK_MEETS_NO FOREIGN KEY(MEETS_NO) REFERENCES MEETS(NO) ON DELETE CASCADE,
    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE
);

-- 게시판 좋아요 테이블
CREATE TABLE ARTICLES_LIKE (
    -- 회원 번호
    MEMBERS_NO           NUMBER                  NOT NULL,
    -- 게시판 번호
    ARTICLES_NO          NUMBER                  NOT NULL,
    
    -- FK
    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE,
    FOREIGN KEY(ARTICLES_NO) REFERENCES ARTICLES(NO) ON DELETE CASCADE
);

-- 댓글 좋아요 테이블
CREATE TABLE REPLIES_LIKE (
    -- 회원 번호
    MEMBERS_NO           NUMBER                  NOT NULL,
    -- 게시판 번호
    ARTICLES_NO          NUMBER                  NOT NULL,
    -- 댓글 번호
    REPLIES_NO           NUMBER                  NOT NULL,
    
    -- FK
    FOREIGN KEY(MEMBERS_NO) REFERENCES MEMBERS(NO) ON DELETE CASCADE,
    FOREIGN KEY(ARTICLES_NO) REFERENCES ARTICLES(NO) ON DELETE CASCADE,
    CONSTRAINT FK_REPLIES_NO FOREIGN KEY(REPLIES_NO) REFERENCES REPLIES(NO) ON DELETE CASCADE
);

-- 모집 인원 관련 테이블
CREATE TABLE MEETS_RECURIT_JOIN (
    -- 모집글 번호
    MEETS_NO                NUMBER,
    -- 회원 번호
    MEMBERS_NO              NUMBER,
    -- 모집글에 참가한 인원을 체크하는 컬럼(참가를 했다 취소한 사람도 체크 
    -- 0: 불참 / 1: 참가
    EXC                     NUMBER(1)               CHECK(EXC IN(0, 1))
);

-- 테이블별 NO 시퀀스
CREATE SEQUENCE ARTICLES_NO_SEQUENCE;

CREATE SEQUENCE MEMBERS_NO_SEQUENCE;

CREATE SEQUENCE REPLIES_NO_SEQUENCE;

CREATE SEQUENCE MEETS_NO_SEQUENCE;

CREATE SEQUENCE MEETS_REPLIES_NO_SEQUENCE;

-- 임시 데이터
INSERT INTO LOCATIONS VALUES(1, '서울특별시');
INSERT INTO LOCATIONS VALUES(2, '경기도');
INSERT INTO LOCATIONS VALUES(3, '강원도');
INSERT INTO LOCATIONS VALUES(4, '충청도');
INSERT INTO LOCATIONS VALUES(5, '전라도');
INSERT INTO LOCATIONS VALUES(6, '경상도');

INSERT INTO FAVORITES(NO, NAME) VALUES(1, '운동');
INSERT INTO FAVORITES(NO, NAME) VALUES(2, '요리');
INSERT INTO FAVORITES(NO, NAME) VALUES(3, '공부');
INSERT INTO FAVORITES(NO, NAME) VALUES(4, '독서');
INSERT INTO FAVORITES(NO, NAME) VALUES(5, '음악');

-- 슈퍼계정
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'AAA', '12', '철수', 'aaa@gmail.com', SYSDATE, 1, 1, 3);
-- 일반계정
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'AAB', '121', '영자', 'aab@gmail.com', SYSDATE, 0, 3, 2);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'AAC', '122', '옥자', 'aac@gmail.com', SYSDATE, 0, 2, 5);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'BBA', '21', '마빡', 'bba@gmail.com', SYSDATE, 0, 5, 4);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'BBB', '211', '맹구', 'bbb@gmail.com', SYSDATE, 0, 4, 3);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'BBC', '212', '유리', 'bbc@gmail.com', SYSDATE, 0, 2, 2);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'CCA', '31', '하마', 'cca@gmail.com', SYSDATE, 0, 3, 1);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'CCB', '311', '탱고', 'ccb@gmail.com', SYSDATE, 0, 5, 5);
INSERT INTO MEMBERS VALUES(MEMBERS_NO_SEQUENCE.NEXTVAL, 'CCC', '312', '천수', 'ccc@gmail.com', SYSDATE, 0, 6, 2);

INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'hello', 'world', 0, sysdate, sysdate, 1, 5);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'my', 'world', 0, sysdate, sysdate, 3, 2);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'your', 'world', 0, sysdate, sysdate, 4, 1);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'her', 'world', 0, sysdate, sysdate, 2, 4);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'him', 'world', 0, sysdate, sysdate, 6, 3);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'girls', 'world', 0, sysdate, sysdate, 7, 2);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'boys', 'world', 0, sysdate, sysdate, 2, 4);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'aunt', 'world', 0, sysdate, sysdate, 1, 1);
INSERT INTO ARTICLES VALUES(ARTICLES_NO_SEQUENCE.NEXTVAL, 'uncle', 'world', 0, sysdate, sysdate, 4, 1);

INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '야이씨', SYSDATE, SYSDATE, 0, 1, 3);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '저이씨', SYSDATE, SYSDATE, 0, 4, 2);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '상놈의씨', SYSDATE, SYSDATE, 0, 3, 1);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '개노무씨', SYSDATE, SYSDATE, 0, 5, 1);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '이자슥씨', SYSDATE, SYSDATE, 0, 7, 5);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '오함마씨', SYSDATE, SYSDATE, 0, 9, 6);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '장도리씨', SYSDATE, SYSDATE, 0, 4, 4);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '어린노무자슥', SYSDATE, SYSDATE, 5, 1, 8);
INSERT INTO REPLIES VALUES(REPLIES_NO_SEQUENCE.NEXTVAL, '이노무자슥', SYSDATE, SYSDATE, 0, 6, 1);

INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 4, 1, '데스윙팟4인', '4인급구', SYSDATE, SYSDATE, SYSDATE + 1, 3, 1);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 10, 1, '데스윙팟10인', '10인급구', SYSDATE, SYSDATE, SYSDATE + 10, 2, 2);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 2, 1, '데스윙팟2인', '2인급구', SYSDATE, SYSDATE, SYSDATE + 5, 1, 7);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 8, 1, '데스윙팟8인', '8인급구', SYSDATE, SYSDATE, SYSDATE + 11, 5, 4);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 21, 1, '데스윙팟21인', '21인급구', SYSDATE, SYSDATE, SYSDATE + 21, 4, 5);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 9, 1, '데스윙팟9인', '9인급구', SYSDATE, SYSDATE, SYSDATE + 12, 1, 5);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 4, 1, '데스윙팟4인', '4인급구', SYSDATE, SYSDATE, SYSDATE + 15, 5, 8);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 6, 1, '데스윙팟6인', '6인급구', SYSDATE, SYSDATE, SYSDATE + 21, 4, 4);
INSERT INTO MEETS VALUES(MEETS_NO_SEQUENCE.NEXTVAL, 2, 1, '데스윙팟2인', '2인급구', SYSDATE, SYSDATE, SYSDATE + 30, 6, 3);

INSERT INTO MEETS_REPLIES VALUES(MEETS_REPLIES_NO_SEQUENCE.NEXTVAL, 'AAA', SYSDATE, SYSDATE, 0, 1, 1);
INSERT INTO MEETS_REPLIES VALUES(MEETS_REPLIES_NO_SEQUENCE.NEXTVAL, 'BBB', SYSDATE, SYSDATE, 0, 1, 2);
INSERT INTO MEETS_REPLIES VALUES(MEETS_REPLIES_NO_SEQUENCE.NEXTVAL, 'CCC', SYSDATE, SYSDATE, 0, 1, 3);

INSERT INTO MEETS_RECURIT_JOIN VALUES(1, 4, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(1, 2, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(1, 10, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(3, 9, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(4, 4, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(4, 8, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(5, 5, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(5, 6, 1);
INSERT INTO MEETS_RECURIT_JOIN VALUES(8, 7, 1);

COMMIT;
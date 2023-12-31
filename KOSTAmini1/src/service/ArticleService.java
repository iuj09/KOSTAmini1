package service;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

import common.CRUD;
import common.Manager;
import common.SERVICE;
import dao.ArticleDao;
import dao.FavoriteDao;
import dao.MemberDao;
import vo.Article;
import vo.Favorite;
import vo.Member;

public class ArticleService extends SERVICE<Article> {
	private MemberService mService;
	private final int perPage = 5;

	public ArticleService(Scanner sc, CRUD<Article> dao, Manager manager) {
		super(sc, dao, manager);
		mService = ((MemberService) this.manager.getService("MemberService"));
	}

	// add. 제목과 내용을 받아서 글쓰기.
	public boolean addArticle(String title, String content) {
		Member user = mService.nowMember();
		if (user == null) {
			System.out.println("로그인 후 이용해주세요.");
			return false;
		}
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			aDao.insert(new Article(0, title, content, 0, null, null, user.getNo(), user.getFavoriteNo()));
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}

//		System.out.println("글 작성 완료.");
		return true;
	}

	// 전체 불러와서 출력
	public void selectArticle() {
		ArrayList<Article> articles;

		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			articles = aDao.select(null);
			printAll(articles);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	// 리스트로 받아온것 그냥 출력
	public void printAll(ArrayList<Article> list) {
		for (Article a : list) {
			System.out.println(a);
		}
	}

	// edit
	public boolean editArticle(int num, String title, String content) {
		Member user = mService.nowMember();
		if (user == null) {
			System.out.println("로그인 후 이용해주세요.");
			return false;
		}
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			if (aDao.getArticle(num).getWriter() == user.getNo() || user.getAdmin().equals("1")) {
					aDao.update(new Article(num, title, content, 0, null, null, 0, 0));
			} else {
				System.out.println("자신의 글만 수정할 수 있습니다.");
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	// del
	public boolean delArticle(int num) {
		Member user = mService.nowMember();
		if (user == null) {
			System.out.println("로그인 후 이용해주세요.");
			return false;
		}
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			if (aDao.getArticle(num).getWriter() == user.getNo() || user.getAdmin().equals("1")) {
					aDao.delete(num);
			} else {
				System.out.println("자신의 글만 삭제할 수 있습니다.");
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	// index를 위한 리스트. 검색 후 page에 따라 페이지네이션하여 articles추출. context 반환.
	public HashMap<String, Object> indexArticle(int pageNum) {
		HashMap<String, Object> context = new HashMap<>();
		Member user = mService.nowMember();
		HashMap<String, Object> args = null;
		if (user != null) {
			args = new HashMap<>();
			args.put("FAVORITES_NO", user.getFavoriteNo());
		}
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			ArrayList<Article> articles = aDao.select1(args);
			ArrayList<Article> sortedArticles = reverseList(articles);
			ArrayList<Article> pageArticles = pagedList(sortedArticles, pageNum);
			int totalArticleCount = articles.size();
			int totalPageCount = (int) Math.ceil((double) sortedArticles.size() / 5);

			context.put("articles", pageArticles);
			context.put("totalPage", totalPageCount);
			context.put("totalArticleCount", totalArticleCount);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return context;
	}

	// printIndex.
	public void printIndex(HashMap<String, Object> context, String msg, int pageNum) {
		ArrayList<Article> articles = (ArrayList<Article>) context.get("articles"); // 팔로우 정렬?
		int totalPage = (int) context.get("totalPage");
		int totalArticleCount = (int) context.get("totalArticleCount");
		System.out.println("=================================== 게시판 ===================================");
		System.out.println("번호                       제목                         작성자         작성일      좋아요");
		System.out.println("---------------------------------------------------------------------------");
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;
				FavoriteDao<Favorite> fDao = ((FavoriteDao<Favorite>) this.manager.getDao("FavoriteDao"));
				MemberDao<Member> mDao = ((MemberDao<Member>) this.manager.getDao("MemberDao"));) {
			if (context.get("articles") == null) {
				System.out.println("게시물이 없습니다.");
			} else {
				for (Article a : articles) {
					String t = "[%s] %s [%d]".formatted(fDao.getName(a.getCategory()), a.getTitle(),
							aDao.repliesCount(a.getNum()));
					System.out.printf(" %-3d | %-40s | %3s | %-1s | %3d\n", articles.indexOf(a) + 1, t,
							mDao.getMember(a.getWriter()).getName(), a.getwDate(), aDao.likeCount(a.getNum()));
				} // 날짜 출력 형식
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("-----------------------------------------------------------");
		System.out.println(pageNum + " / " + totalPage + " (" + totalArticleCount + ")");
		System.out.printf(msg);

	}

	// detail. article 객체를 받음
	public HashMap<String, Object> detailArticle(Article a) {
		HashMap<String, Object> context = new HashMap<>();
		Member user = mService.nowMember();
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			int likeCount = aDao.likeCount(a.getNum());
			int repliesCount = aDao.repliesCount(a.getNum());
			boolean islike = false;
			if (user != null) {
				islike = aDao.isLike(user.getNo(), a.getNum());
			}

			context.put("likeCount", likeCount);
			context.put("repliesCount", repliesCount);
			context.put("islike", islike);

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return context;
	}

	// printDetail
	public void printDetail(Article a, String msg) {
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;
				MemberDao<Member> mDao = ((MemberDao<Member>) this.manager.getDao("MemberDao"));) {
			System.out.println("글번호 : " + a.getNum());
			System.out.println("제목  : " + a.getTitle());
			System.out.println("작성일 : " + a.getwDate());
			System.out.println("작성자 : " + mDao.getMember(a.getWriter()).getName());
			System.out.println("좋아요 수: " + aDao.likeCount(a.getNum())); // context
			System.out.println("댓글 수: " + aDao.repliesCount(a.getNum())); // context
			System.out.println("-------------------------------------------");
			System.out.println(a.getContent());
			System.out.println("-------------------------------------------");
			System.out.printf(msg);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	// search 결과 articles추출. context 반환.
	public HashMap<String, Object> searchArticles(String s, int cmd, int pageNum) {
		HashMap<String, Object> context = new HashMap<>();
		Member user = mService.nowMember();
		HashMap<String, Object> args = new HashMap<>();

		ArrayList<Article> articles = new ArrayList<>();
		int fId = 0;

		if (user != null) {
			fId = user.getFavoriteNo();
		}

		if (cmd < 4) {
			String[] words = s.split(" ");
			if (cmd == 1 || cmd == 3) {
				for (String w : words) {
					args.put("title", w);
				}
			}
			if (cmd == 2 || cmd == 3) {
				for (String w : words) {
					args.put("content", w);
				}
			}
		} else if (cmd == 4) { // name으로 검색
			args.put("name", s);
		} else if (cmd == 5) { // id로 검색
			args.put("id", s);
		}
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			articles = aDao.searchJoinMember(args, fId);

			ArrayList<Article> sortedArticles = reverseList(articles);
			ArrayList<Article> pageArticles = pagedList(sortedArticles, pageNum);
			int totalPageCount = (int) Math.ceil((double) sortedArticles.size() / 5);
			int totalArticleCount = articles.size();

			context.put("articles", pageArticles);
			context.put("totalPage", totalPageCount);
			context.put("totalArticleCount", totalArticleCount);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return context;
	}

	// searchByMId
	public ArrayList<Article> searchByMemberNo(int num) {
		ArrayList<Article> articles = new ArrayList<>();
		HashMap<String, Object> args = new HashMap<>() {
			{
				put("MEMBERS_NO", num);
			}
		};
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			articles = aDao.select1(args);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return articles;
	}

	// 좋아요 토글
	public String likeArticle(Article a) {
		Member user = mService.nowMember();
		String msg = "";
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			if (user == null) {
				msg = "로그인 후 이용해주세요.\n";
			} else {
				if (aDao.isLike(user.getNo(), a.getNum())) {
					aDao.dislikeArticle(user.getNo(), a.getNum());
					msg = a.getNum() + " 번 게시글을 좋아요 취소했습니다.\n";
				} else {
					aDao.likeArticle(user.getNo(), a.getNum());
					msg = a.getNum() + " 번 게시글을 좋아요 했습니다.\n";
				}
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return msg;
	}

	// 좋아요한 게시물 반환
	public ArrayList<Article> likedArticles(int num) {
		ArrayList<Article> list = new ArrayList<>();
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			list = aDao.getLikedArticles(num);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	// 원본list와 페이지num을 param으로 받아서 페이지네이션된 리스트 반환
	public ArrayList<Article> pagedList(ArrayList<Article> list, int page) {
		ArrayList<Article> pagedList = new ArrayList<>(perPage);

		int startArticleIndex = (page - 1) * perPage;
		int endArticleIndex = Math.min(page * perPage, list.size());

		if (startArticleIndex >= endArticleIndex || startArticleIndex < 0) {
			return null;
		}

		pagedList = new ArrayList<>(list.subList(startArticleIndex, endArticleIndex));

		return pagedList;
	}

	// 정렬이 반대인 복사본 리스트를 반환.
	public ArrayList<Article> reverseList(ArrayList<Article> list) {
		ArrayList<Article> reverse = new ArrayList<>(list.size());

		for (int i = list.size() - 1; i >= 0; i--) {
			reverse.add(list.get(i));
		}
		return reverse;
	}

	public Article getArticle(int num) {
		Article article = new Article();
		try (ArticleDao<Article> aDao = (ArticleDao<Article>) this.dao;) {
			article = aDao.getArticle(num);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return article;

	}
}

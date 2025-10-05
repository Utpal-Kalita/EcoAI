import os
from dotenv import load_dotenv
from langchain_cerebras import ChatCerebras
from langchain.vectorstores import FAISS
from langchain.chains import RetrievalQA
from langchain_huggingface import HuggingFaceEmbeddings

load_dotenv()

def setup_rag_chain():
    """
    Setup RAG chain with error handling for missing FAISS index
    Returns None if setup fails
    """
    try:
        # Load embeddings
        embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5")
        
        # Check if FAISS index exists
        if not os.path.exists("data/climate_docs"):
            print("⚠️  Warning: FAISS index not found at data/climate_docs")
            print("   Run preprocess.py to build the index")
            return None
        
        # Load FAISS vector store
        vectorstore = FAISS.load_local(
            "data/climate_docs", 
            embeddings=embeddings, 
            allow_dangerous_deserialization=True
        )
        
        # Setup LLM with Cerebras (fast inference)
        api_key = os.getenv("CEREBRAS_API_KEY")
        if not api_key:
            print("⚠️  Warning: CEREBRAS_API_KEY not set")
            return None
            
        llm = ChatCerebras(
            model="llama3.1-8b",
            api_key=api_key,
            max_tokens=512,
            temperature=0.7,
        )
        
        # Setup RAG chain
        rag_chain = RetrievalQA.from_chain_type(
            llm=llm,
            chain_type="stuff",
            retriever=vectorstore.as_retriever(search_kwargs={"k": 3}),
        )
        
        print("✅ RAG chain setup complete")
        return rag_chain
        
    except Exception as e:
        print(f"⚠️  Error setting up RAG chain: {e}")
        print("   AI service will run in fallback mode")
        return None
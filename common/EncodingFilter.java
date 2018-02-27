package org.water.common;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class EncodingFilter extends HttpServlet implements Filter
{
	@SuppressWarnings("unused")
	private FilterConfig filterConfig;
	private String encoding = null;
	protected boolean ignore = true;
	private static Log log = LogFactory.getLog(EncodingFilter.class);

	public void init(FilterConfig filterConfig) throws ServletException
	{
		this.filterConfig = filterConfig;
		this.encoding = filterConfig.getInitParameter("encoding");
		String value = filterConfig.getInitParameter("ignore");
		if (value == null)
		{
			this.ignore = true;
		} else if (value.equalsIgnoreCase("true"))
		{
			this.ignore = true;
		} else if (value.equalsIgnoreCase("yes"))
		{
			this.ignore = true;
		} else
		{
			this.ignore = false;
		}
	}

	// Process the request/response pair
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain)
	{
		try
		{
			if (ignore || (request.getCharacterEncoding() == null))
			{
				String encoding = selectEncoding(request);
				if (encoding != null)
					request.setCharacterEncoding(encoding);
			}
			
			filterChain.doFilter(request, response);
		} 
		catch (Exception sx)
		{
			System.out.println(sx.getMessage());
			//log.error(sx.getMessage());
		}

	}

	private String selectEncoding(ServletRequest request)
	{
		return (this.encoding);
	}

	// Clean up resources
	public void destroy()
	{
		encoding = null;
		filterConfig = null;
	}
}
